#!/bin/bash

##traffic accounting
iptables -N ACCOUNTING_INPUT_CHAIN
iptables -N ACCOUNTING_OUTPUT_CHAIN

iptables -I INPUT -j ACCOUNTING_INPUT_CHAIN
iptables -I OUTPUT -j ACCOUNTING_OUTPUT_CHAIN

ARRAY=(`seq 2 15` `seq 20 31` `seq 251 254`)
for i in ${ARRAY[@]}; do
	iptables -A ACCOUNTING_INPUT_CHAIN -s 192.168.234.$i/32 -j RETURN
	iptables -A ACCOUNTING_OUTPUT_CHAIN -d 192.168.234.$i/32 -j RETURN
done
iptables -A ACCOUNTING_INPUT_CHAIN -s 192.168.234.0/24 -j RETURN
iptables -A ACCOUNTING_OUTPUT_CHAIN -d 192.168.234.0/24 -j RETURN

iptables -A ACCOUNTING_INPUT_CHAIN -j RETURN
iptables -A ACCOUNTING_OUTPUT_CHAIN -j RETURN
