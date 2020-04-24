#!/bin/bash

#update accounting hosts
#should run periodly

ARRAY=(`cat /proc/net/arp | grep : | grep ^192.168.| grep -v 00:00:00:00:00:00| awk '{print $1}'`)
oldtable=`iptables -L ACCOUNTING_DOWNLOAD_CHAIN -xn`

for ip in ${ARRAY[@]}; do
    if !(echo $oldtable |grep $ip > /dev/null); then
	echo adding $ip into accounting table
        iptables -A ACCOUNTING_DOWNLOAD_CHAIN ! -s 192.168.0.0/16 -d $ip/32 -j RETURN
        iptables -A ACCOUNTING_UPLOAD_CHAIN   ! -d 192.168.0.0/16 -s $ip/32 -j RETURN
    fi
done

-
