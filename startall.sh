#!/bin/bash
while read a; do
                        if [[ "$a" = conn* && ! "$a" = "conn %default" ]]; then
                                k="${a##* }"
                                sudo ipsec up "$k"
                        fi
                done<$1
