#!/bin/bash
while read a; do
                        if [[ "$a" = conn* && ! "$a" = "conn %default" ]]; then
                                k="${a##* }"
                                ipsec status > tempstat.txt
                                ktemp=$(grep -c "$k" tempstat.txt)
                                if [ $ktemp -eq 0 ]
                                then
                                ipsec up "$k"
                                fi
                                rm tempstat.txt
                        fi
                done<"/etc/ipsec.conf"
