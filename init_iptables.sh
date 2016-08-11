#!/bin/bash

iptables -F TRAFFIC_ACCT_IN
iptables -F TRAFFIC_ACCT_OUT
iptables -N TRAFFIC_ACCT_IN
iptables -N TRAFFIC_ACCT_OUT
iptables -I INPUT -j TRAFFIC_ACCT_IN
iptables -I OUTPUT -j TRAFFIC_ACCT_OUT

ARRAY=(82 8123 80 443 22)
for i in ${ARRAY[@]}; do
         iptables -I TRAFFIC_ACCT_OUT -p tcp --sport $i -m comment --comment "port $i TCP download"
         iptables -I TRAFFIC_ACCT_OUT -p udp --sport $i -m comment --comment "port $i UDP download"
         iptables -I TRAFFIC_ACCT_IN  -p tcp --dport $i -m comment --comment "port $i TCP upload"
         iptables -I TRAFFIC_ACCT_IN  -p udp --dport $i -m comment --comment "port $i UDP upload"
done
