#!/bin/sh

# Reference files for approved users and admins
USERS_REFERENCE="../util/info/users.txt"
ADMINS_REFERENCE="../util/info/admins.txt"

# Define suspicious groups that users shouldn't have
SUSPICIOUS_GROUPS=$(cat ../util/info/suspicious_groups.txt)

# Function to check if a user belongs to any suspicious groups
check_suspicious_groups() {
    username="$1"
    suspicious_found=""
    
    # Get all groups for the user
    user_groups=$(id -Gn "$username" 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        for group in $user_groups; do
            for suspicious in $SUSPICIOUS_GROUPS; do
                if [ "$group" = "$suspicious" ]; then
                    suspicious_found="$suspicious_found $group"
                fi
            done
        done
    fi
    
    echo "$suspicious_found"
}

check_if_approved() {
    echo "##### Users #####"
    
    if [ ! -f "$USERS_REFERENCE" ]; then
        echo "Warning: Users reference file not found: $USERS_REFERENCE"
        return 1
    fi
    
    if [ ! -f "$ADMINS_REFERENCE" ]; then
        echo "Warning: Admins reference file not found: $ADMINS_REFERENCE"
        return 1
    fi
    
    # Read /etc/passwd and check each user
    while IFS=":" read -r user _ uid _ _ _ shell; do
        # Skip users with nologin shell
        if [ "$shell" = "/usr/sbin/nologin" ] || [ "$shell" = "/sbin/nologin" ] || [ "$shell" = "/bin/false" ]; then
            continue
        fi
        
        # Check if user is in approved users list
        user_approved=$(grep -Fx "$user" "$USERS_REFERENCE" 2>/dev/null)
        
        # Check if user is in approved admins list
        admin_approved=$(grep -Fx "$user" "$ADMINS_REFERENCE" 2>/dev/null)
        
        if [ -z "$user_approved" ] && [ -z "$admin_approved" ]; then
            echo "ALERT: User '$user' (UID: $uid) not in approved users or admins list! Shell: $shell"
        else
            # User is approved, check for suspicious groups
            suspicious_groups=$(check_suspicious_groups "$user")
            
            if [ -n "$suspicious_groups" ]; then
                if [ -n "$user_approved" ]; then
                    echo "WARNING: Approved user '$user' has suspicious groups:$suspicious_groups"
                elif [ -n "$admin_approved" ]; then
                    echo "INFO: Approved admin '$user' has elevated groups:$suspicious_groups (this may be expected)"
                fi
            fi
        fi
        
    done < "/etc/passwd"
    
    echo ""
    echo "##### Admins #####"
    
    # Check members of wheel/sudo groups who might not be in passwd with shells
    for group in wheel sudo admin; do
        if group_members=$(getent group "$group" 2>/dev/null); then
            group_name=$(echo "$group_members" | cut -d: -f1)
            members=$(echo "$group_members" | cut -d: -f4 | tr ',' ' ')
            
            if [ -n "$members" ]; then
                echo "Members of $group_name group: $members"
                for member in $members; do
                    admin_approved=$(grep -Fx "$member" "$ADMINS_REFERENCE" 2>/dev/null)
                    if [ -z "$admin_approved" ]; then
                        echo "ALERT: User '$member' in $group_name group but not in approved admins list!"
                    fi
                done
            fi
        fi
    done
}

ssh() {
    KEYS_DIR="../util/files/ssh_keys"
    mkdir -p "$KEYS_DIR"

    if ! command -v ssh-keygen >/dev/null 2>&1; then
        echo "ERROR: ssh-keygen not found; cannot create keys"
        return 1
    fi

    while IFS= read -r u || [ -n "$u" ]; do
        # Trim whitespace and skip empty/comment lines
        u=$(echo "$u" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
        [ -z "$u" ] && continue
        case "$u" in \#*) continue ;; esac

        priv="$KEYS_DIR/$u"
        pub="$priv.pub"

        # Remove existing keys and create new ones
        rm -f "$priv" "$pub" 2>/dev/null || true
        if ssh-keygen -t ed25519 -a 100 -f "$priv" -N "" -C "$u@$(hostname)" >/dev/null 2>&1; then
            echo "Rotated SSH key for '$u': $pub"
        else
            echo "ERROR: Failed to create SSH key for '$u'"
            continue
        fi

        pub_content=$(cat "$pub")

        # Move key to user's home directory
        user_entry="$(getent passwd "$u" 2>/dev/null || awk -F: -v user="$u" '($1==user){print; exit}' /etc/passwd)"
        if [ -n "$user_entry" ]; then
            user_home=$(echo "$user_entry" | cut -d: -f6)
            if [ -z "$user_home" ]; then
                echo "WARN: Could not determine home for user '$u' — writing fallback authorized file"
                echo "$pub_content" > "$KEYS_DIR/authorized_keys_for_$u"
                continue
            fi

            ssh_dir="$user_home/.ssh"
            authorized="$ssh_dir/authorized_keys"

            # Create .ssh and set permissions
            if [ ! -d "$ssh_dir" ]; then
                if mkdir -p "$ssh_dir"; then
                    echo "Created $ssh_dir"
                else
                    echo "ERROR: Failed to create $ssh_dir for user '$u' — writing fallback file"
                    echo "$pub_content" > "$KEYS_DIR/authorized_keys_for_$u"
                    continue
                fi
            fi

            chmod 700 "$ssh_dir" 2>/dev/null || true

            # Ensure authorized_keys exists
            touch "$authorized" 2>/dev/null || true
            chmod 600 "$authorized" 2>/dev/null || true

            # Backup existing authorized_keys and install only the new key
            if [ -f "$authorized" ]; then
                bak="$authorized.bak.$(date +%s)"
                if cp "$authorized" "$bak" 2>/dev/null; then
                    echo "Backed up existing $authorized -> $bak"
                else
                    echo "WARN: Could not back up $authorized"
                fi
            fi

            # Write the new key as the sole authorized key
            printf "%s\n" "$pub_content" > "$authorized" 2>/dev/null || {
                echo "ERROR: Could not write $authorized for user '$u'"
                echo "$pub_content" > "$KEYS_DIR/authorized_keys_for_$u"
                echo "Wrote fallback $KEYS_DIR/authorized_keys_for_$u"
                continue
            }
            chmod 600 "$authorized" 2>/dev/null || true
            chmod 700 "$ssh_dir" 2>/dev/null || true

            # Attempt to set ownership to the user
            if command -v chown >/dev/null 2>&1; then
                chown "$u":"$u" "$ssh_dir" "$authorized" 2>/dev/null || echo "WARN: Could not chown $ssh_dir/$authorized to $u"
            fi

            echo "Replaced authorized_keys for '$u' with new key"
        else
            # If we ever get to here, the user was removed for some reason
            echo "WARN: User '$u' not found on system — writing $KEYS_DIR/authorized_keys_for_$u"
            echo "$pub_content" > "$KEYS_DIR/authorized_keys_for_$u"
        fi
    done < "$USERS_REFERENCE"
}

users() {
    check_if_approved
    ssh
}

users