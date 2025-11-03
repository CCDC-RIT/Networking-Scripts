#!/bin/sh

# Reference files for approved users and admins
USERS_REFERENCE="../util/info/users.txt"
ADMINS_REFERENCE="../util/info/admins.txt"

# Define suspicious groups that users shouldn't have
SUSPICIOUS_GROUPS="wheel sudo admin root operator"

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

users() {
    echo "#####Users#####"
    
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
    echo "#####Admins#####"
    
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

users