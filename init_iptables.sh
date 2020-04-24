#!/bin/bash

iptables -N ACCOUNTING_DOWNLOAD_CHAIN
iptables -N ACCOUNTING_UPLOAD_CHAIN
iptables -F ACCOUNTING_DOWNLOAD_CHAIN
iptables -F ACCOUNTING_UPLOAD_CHAIN

iptables -I FORWARD ! -s 192.168.0.0/16 -d 192.168.0.0/16 -j ACCOUNTING_DOWNLOAD_CHAIN -m comment --comment "下载流量统计"
iptables -I FORWARD -s 192.168.0.0/16 ! -d 192.168.0.0/16 -j ACCOUNTING_UPLOAD_CHAIN   -m comment --comment "上传流量统计"

ARRAY=(`cat /proc/net/arp | grep : | grep ^192.168 | grep -v 00:00:00:00:00:00| awk '{print $1}'`)
for ip in ${ARRAY[@]}; do
    echo adding $ip into accounting table
    iptables -A ACCOUNTING_DOWNLOAD_CHAIN ! -s 192.168.0.0/16 -d $ip/32 -j RETURN
    iptables -A ACCOUNTING_UPLOAD_CHAIN   ! -d 192.168.0.0/16 -s $ip/32 -j RETURN
done

