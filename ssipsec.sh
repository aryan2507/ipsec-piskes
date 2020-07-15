#!/bin/bash
ipsec stop
ipsec start
ifconfig |  grep -w "inet*" >>temp.txt
awk -F ' ' '{print $2;}' temp.txt > a.txt
awk -F ':' '{print $2;}' a.txt >temp.txt
rm a.txt
while read -r a;
do
        b=":"
        c="$a$b"
        echo $c
        result=$(grep -n "$c" "conf/topology.json")
        check=0
        linenum=-1
        IFS=':'
        read -ra ADDR <<< "$result"
        for i in "${ADDR[@]}"; do
                if [ $linenum -eq -1 ]
                then
                        linenum=$i
                fi
                if [[ "$i" == *public* ]]
                then
                        echo $i
                        check=1
                fi
        done
        IFS=' '
        remote="a"
        if [ $check -eq 1 ]
        then
                linenum=$((linenum+1))
                fin=$(sed "${linenum}q;d" "conf/topology.json")
                IFS=':'
                e=0
                read -ra ADDR <<< "$fin"
                for i in "${ADDR[@]}"; do
                        if [ $e -eq 1 ]
                        then
                                remote=$i
                        fi
                        e=$((e+1))
                done
                echo $a
                remote=${remote:2}
                echo $remote
                . ./add.sh "$remote" "$a"
        fi
        IFS=' '
	. ./startall.sh
done<"temp.txt"
rm temp.txt
