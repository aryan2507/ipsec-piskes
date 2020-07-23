#!/bin/bash
ipsec start
p=0
grep -w "public" conf/topology.json >>temp1.txt
grep -w "remote" conf/topology.json >>temp2.txt
ifconfig >>temp3.txt
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

srcashelp=$( grep -m 1 "isd_as" conf/topology.json )
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
#echo $sciond
while read -r a;
do
        size=${#a}
        p=$((p+1))
        remote=$(sed "${p}q;d" "temp2.txt")
        if [ $size -ge 30 ]
        then
                ans=$( ipv6 "$a" )
                ch=$(grep -w "$ans" temp3.txt)
                if [[ $ch == "" ]]
                then
                        continue
                fi
                ansr=$( ipv6 "$remote" )
                dstashelp=$(  awk -v pattern="$ansr" '$0 ~ pattern {f=1} f && /"isd_as"/ {print; exit}' conf/topology.json )
                dstas=$( getas "$dstashelp" )
                cd /app
                pass=$( ./drkeymockup "$srcas" "$dstas" "$ans" "$ansr" "$sciond" )
                echo $pass
                cd /share
                . ./add.sh "$ansr" "$ans" "$pass"
                continue
        fi
        ans=$( ipv4 "$a" )
        ch=$(grep -w "$ans" temp3.txt)
        if [[ $ch == "" ]]
        then
        continue
        fi
        ansr=$( ipv4 "$remote" )
        dstashelp=$(  awk -v pattern="$ansr" '$0 ~ pattern {f=1} f && /"isd_as"/ {print; exit}' conf/topology.json )
        dstas=$( getas "$dstashelp" )
        cd /app
        pass=$( ./drkeymockup "$srcas" "$dstas" "$ans" "$ansr" "$sciond" )
        echo $pass
        cd /share
        . ./add.sh "$ansr" "$ans" "$pass"
done<"temp1.txt"
ipsec restart
sleep 1.5
BACK_PID=$!
wait $BACK_PID
rm temp1.txt
rm temp2.txt
rm temp3.txt
