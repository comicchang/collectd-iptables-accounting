#!/bin/bash

iptables -N ACCOUNTING_INPUT_CHAIN
iptables -N ACCOUNTING_OUTPUT_CHAIN
iptables -F ACCOUNTING_INPUT_CHAIN
iptables -F ACCOUNTING_OUTPUT_CHAIN

iptables -I FORWARD -j ACCOUNTING_INPUT_CHAIN
iptables -I FORWARD -j ACCOUNTING_OUTPUT_CHAIN

ARRAY=(`cat /proc/net/arp | grep : | grep ^192 | grep -v 00:00:00:00:00:00| awk '{print $1}'`)
for ip in ${ARRAY[@]}; do
    iptables -A ACCOUNTING_INPUT_CHAIN ! -d 192.168.234.0/24 -s $ip/32 -j RETURN
    iptables -A ACCOUNTING_OUTPUT_CHAIN ! -s 192.168.234.0/24 -d $ip/32 -j RETURN
done

