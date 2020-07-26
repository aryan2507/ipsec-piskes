#!/bin/bash
p=0
while read -r a;
do
        if [ "$a" = "conn $1" ]; then
         let "p = $p + 1"
        fi
done<"/etc/ipsec.conf"
if [ $p -eq 0 ]
then
        echo "conn $1
                ikelifetime=1442m
                keylife=1440m
                rekeymargin=3m
                keyingtries=1
                keyexchange=ikev2
                authby=secret
                left=$2
                right=$1
                leftsubnet=%dynamic
                rightsubnet=%dynamic
                auto=add" | tee -a "/etc/ipsec.conf"
                k="${1} : PSK ${3}"
        echo "$k"| dd status=none of="/etc/ipsec.secrets"
else
        /bin/bash /share/rekey.sh $1 $3
fi
