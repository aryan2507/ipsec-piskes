#!/bin/bash
p=0
while read -r a; 
do
	if [ "$a" = "conn $1" ]; then
         let "p = $p + 1"
	fi
done<$2
if [ $p -eq 0 ]
then
	echo "conn $1
	        ikelifetime=60m
		keylife=20m
		rekeymargin=3m
		keyingtries=1
		keyexchange=ikev2
		authby=secret
		left=$3
		right=$1
		leftsubnet=%dynamic
		rightsubnet=%dynamic
		auto=add"| sudo tee -a $2
		sudo ipsec restart
fi	
