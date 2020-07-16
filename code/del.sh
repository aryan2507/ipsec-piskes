#!/bin/bash
t=$(fgrep -w -m1 "$1" "$2")
r=0
q="-1"
check="false"
while read a;do
	let "r = $r + 1 "
	if [ "$a" = "$t" ]; then
		q="$r"
		check="true"
		break
	fi
done< /etc/ipsec.conf
if [ "$check" = "true" ]; then
	q+="d"
	for value in {12..1..1};do
		sudo sed -i -e "$q" "$2"
	done
fi
