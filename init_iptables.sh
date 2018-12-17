#!/bin/bash

##traffic accounting
##traffic accounting
iptables -N ACCOUNTING_INPUT_CHAIN
iptables -N ACCOUNTING_OUTPUT_CHAIN
iptables -F ACCOUNTING_INPUT_CHAIN
iptables -F ACCOUNTING_OUTPUT_CHAIN

iptables -I FORWARD -j ACCOUNTING_INPUT_CHAIN
iptables -I FORWARD -j ACCOUNTING_OUTPUT_CHAIN

ARRAY=(`seq 2 15` `seq 20 31` `seq 251 254`)
for i in ${ARRAY[@]}; do
	iptables -A ACCOUNTING_INPUT_CHAIN ! -d 192.168.234.0/24 -s 192.168.234.$i/32 -j RETURN
	iptables -A ACCOUNTING_OUTPUT_CHAIN ! -s 192.168.234.0/24 -d 192.168.234.$i/32 -j RETURN
done
