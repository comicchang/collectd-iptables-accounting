#!/bin/bash

#update accounting hosts
#should run periodly

ARRAY=(`cat /proc/net/arp | grep : | grep ^192 | grep -v 00:00:00:00:00:00| awk '{print $1}'`)
oldtable=`iptables -L ACCOUNTING_INPUT_CHAIN -xn`

for ip in ${ARRAY[@]}; do
    if !(echo $oldtable |grep $ip > /dev/null); then
        iptables -A ACCOUNTING_INPUT_CHAIN ! -d 192.168.234.0/24 -s $ip/32 -j RETURN
        iptables -A ACCOUNTING_OUTPUT_CHAIN ! -s 192.168.234.0/24 -d $ip/32 -j RETURN
    fi
done


