#!/bin/bash
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
                . ./add.sh "$ansr" "$ans"
                continue
        fi
        ans=$( ipv4 "$a" )
        ch=$(grep -w "$ans" temp3.txt)
        if [[ $ch == "" ]]
        then
        continue
        fi
        ansr=$( ipv4 "$remote" )
        . ./add.sh "$ansr" "$ans"
done<"temp1.txt"
ipsec start
rm temp1.txt
rm temp2.txt
rm temp3.txt
