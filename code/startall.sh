#!/bin/bash
while read a; do
                        if [[ "$a" = conn* && ! "$a" = "conn %default" ]]; then
                                k="${a##* }"
                                ipsec status > /share/tempstat.txt
                                ktemp=$(grep -c "$k" /share/tempstat.txt)
                                if [ $ktemp -eq 0 ]
                                then
                                ipsec up "$k"
                                fi
                                rm /share/tempstat.txt
                        fi
                done<"/etc/ipsec.conf"
