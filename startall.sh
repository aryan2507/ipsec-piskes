#!/bin/bash
ipsec restart
while read a; do
                        if [[ "$a" = conn* && ! "$a" = "conn %default" ]]; then
                                k="${a##* }"
                                ipsec up "$k"
                        fi
                done<"/etc/ipsec.conf"
