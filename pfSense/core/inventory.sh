#!/bin/sh

# List all users
users() {
    ADMIN_GROUP="admins"
    ADMIN_USERS=$(grep "^$ADMIN_GROUP:" /etc/group | cut -d: -f4 | tr ',' '\n')

    echo "##### Non System Users #####"
    while IFS=: read -r username _ uid _ _ home _; do
        if [ "$uid" -ge 1000 ]; then
            output="$username"
            # Check for admin perms
            if echo "$ADMIN_USERS" | grep -qw "$username"; then
                output="$output ADMIN"
            fi

            # Check for SSH key
            if [ -f "$home/.ssh/authorized_keys" ]; then
                output="$output SSH"
            fi
            echo "$output"
        fi
    done < /etc/passwd

    echo ""
}

services() {
    echo "##### Non-Default Services #####"
    service -e > ../util/files/compare_services.txt
    cd ../util || echo "util directory is missing"
    diff --suppress-common-lines files/compare_services.txt info/default_services.txt
    cd ../core || echo "core direcotry is missing"
    echo ""
}

# List zones
interfaces() {
    echo "##### Network interfaces #####"
    ifconfig -l | tr ' ' '\n' | while read iface; do
        echo "$iface"
    done

    IFACE_COUNT=$(ifconfig -l | wc -w)
    echo "Number of network interfaces: $IFACE_COUNT"
    echo ""
}

# List firewall rules
firewall() {
    if [ -f /cf/conf/config.xml ]; then
        echo "Firewall rules:"
        awk 'BEGIN { RS="<rule>"; FS="\n" }
NR>1 {
  descr=""; type=""; iface=""; src=""; dst=""
  ins=0; ind=0

  for (i=1; i<=NF; i++) {
    line=$i

    # Enter/exit blocks (MUST use continue, not next)
    if (line ~ /<source>/)        { ins=1; continue }
    if (line ~ /<\/source>/)      { ins=0; continue }
    if (line ~ /<destination>/)   { ind=1; continue }
    if (line ~ /<\/destination>/) { ind=0; continue }

    # Top-level fields
    if (line ~ /<descr>/) {
      tmp=line
      sub(/.*<descr>/, "", tmp)
      sub(/<\/descr>.*/, "", tmp)
      descr=tmp
      continue
    }

    if (line ~ /<type>/) {
      tmp=line
      sub(/.*<type>/, "", tmp)
      sub(/<\/type>.*/, "", tmp)
      type=tmp
      continue
    }

    if (line ~ /<interface>/) {
      tmp=line
      sub(/.*<interface>/, "", tmp)
      sub(/<\/interface>.*/, "", tmp)
      iface=tmp
      continue
    }

    # Source block parsing
    if (ins) {
      if (line ~ /<any\/>/) { src="any"; continue }
      if (line ~ /<network>/) {
        tmp=line
        sub(/.*<network>/, "", tmp)
        sub(/<\/network>.*/, "", tmp)
        src=tmp
        continue
      }
      if (line ~ /<address>/) {
        tmp=line
        sub(/.*<address>/, "", tmp)
        sub(/<\/address>.*/, "", tmp)
        src=tmp
        continue
      }
    }

    # Destination block parsing
    if (ind) {
      if (line ~ /<any\/>/) { dst="any"; continue }
      if (line ~ /<network>/) {
        tmp=line
        sub(/.*<network>/, "", tmp)
        sub(/<\/network>.*/, "", tmp)
        dst=tmp
        continue
      }
      if (line ~ /<address>/) {
        tmp=line
        sub(/.*<address>/, "", tmp)
        sub(/<\/address>.*/, "", tmp)
        dst=tmp
        continue
      }
    }
  }

  # Skip empty records
  if (iface=="" && descr=="" && type=="" && src=="" && dst=="") next

  if (src=="") src="unspecified"
  if (dst=="") dst="unspecified"
  if (descr=="") descr="no description"
  if (type=="") type="no type"

 # Clean description
  gsub(/[<>!\[\]]/, "", descr)
  gsub(/CDATA/, "", descr)


  printf "%-10s %-8s %-15s %-15s %s\n",
       iface, type, src, dst, descr
}
' /cf/conf/config.xml
    else
        echo "Firewall config not found."
    fi

    echo ""
}

inventory() {
    users
    services
    interfaces
    firewall
}

inventory