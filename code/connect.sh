#!/bin/bash
if [ "$1" == "establish" ]
then
        ipsec start
        (crontab -l 2>/dev/null; echo "0 0 * * * /bin/bash /share/connect.sh") | crontab -
        service cron start
fi
p=0
grep -w "public" /share/conf/topology.json >>/share/temp1.txt
grep -w "remote" /share/conf/topology.json >>/share/temp2.txt
/sbin/ifconfig >>/share/temp3.txt
ipv4 () {

        IFS=':'
        read -ra ADDR <<< "$1"
        e=0
        k=" "
        for i in "${ADDR[@]}"; do
           if [ $e -eq 1 ]
           then
                k=$i
           fi
           e=$((e+1))
         done
        k="${k:2}"
        IFS=' '
        echo $k
}

ipv6 () {

        IFS='['
        read -ra ADDR <<< "$1"
        e=0
        k=" "
        for i in "${ADDR[@]}"; do
           if [ $e -eq 1 ]
           then
                k=$i
           fi
           e=$((e+1))
         done
        IFS=' '
        qq=" "
        IFS=']'
        read -ra ADDR <<< "$k"
        e=0
        k=" "
        for i in "${ADDR[@]}"; do
           if [ $e -eq 0 ]
           then
                qq=$i
           fi
           e=$((e+1))
         done
        IFS=' '
        echo $qq
}

getas () {
IFS='"'
        read -ra ADDR <<< "$1"
        e=0
        k=" "
        for i in "${ADDR[@]}"; do
           if [ $e -eq 3 ]
           then
                k=$i
           fi
           e=$((e+1))
         done
        IFS=' '
        echo $k
}

srcashelp=$( grep -m 1 "isd_as" /share/conf/topology.json )
srcas=$( getas "$srcashelp" )
sciond="scion_sd"
IFS=':'
     read -ra ADDR <<< "$srcas"
        e=0
     for i in "${ADDR[@]}"; do
        sciond="${sciond}${i}"
        if [ $e -lt 2 ]
        then
                sciond="${sciond}_"
        fi
        e=$((e+1))
    done
IFS=' '
sciond="${sciond}:30255"
ansr=" "
while read -r a;
do
        size=${#a}
        p=$((p+1))
        remote=$(sed "${p}q;d" "/share/temp2.txt")
        if [ $size -ge 30 ]
        then
                ans=$( ipv6 "$a" )
                ch=$( grep -w "$ans" "/share/temp3.txt" )
                if [[ $ch == "" ]]
                then
                        continue
                fi
                ansr=$( ipv6 "$remote" )
                dstashelp=$(  awk -v pattern="$ansr" '$0 ~ pattern {f=1} f && /"isd_as"/ {print; exit}' "/share/conf/topology.json" )
                dstas=$( getas "$dstashelp" )
                pass=$( /app/drkeymockup "$srcas" "$dstas" "$ans" "$ansr" "$sciond" )
                /bin/bash /share/add.sh "$ansr" "$ans" "$pass"
                continue
        fi
        ans=$( ipv4 "$a" )
        ch=$( grep -w "$ans" "/share/temp3.txt" )
        if [[ $ch == "" ]]
        then
        continue
        fi
        ansr=$( ipv4 "$remote" )
        dstashelp=$(  awk -v pattern="$ansr" '$0 ~ pattern {f=1} f && /"isd_as"/ {print; exit}' "/share/conf/topology.json" )
        dstas=$( getas "$dstashelp" )
        pass=$( /app/drkeymockup "$srcas" "$dstas" "$ans" "$ansr" "$sciond" )
        /bin/bash /share/add.sh "$ansr" "$ans" "$pass"
done<"/share/temp1.txt"
if [ "$1" == "establish" ]
then
        ipsec restart
        sleep 1.5
        BACK_PID=$!
        wait $BACK_PID
else
        ipsec rereadsecrets
        ipsec reload
fi
rm /share/temp1.txt
rm /share/temp2.txt
rm /share/temp3.txt
