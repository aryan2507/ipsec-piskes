#!/bin/bash
linenum=$( grep -n "$1" "/etc/ipsec.secrets" | cut -f1 -d: )
d="d"
linenum="${linenum}${d}"
sed -i $linenum "/etc/ipsec.secrets"
echo "$1 : PSK $2"| dd status=none of="/etc/ipsec.secrets"
