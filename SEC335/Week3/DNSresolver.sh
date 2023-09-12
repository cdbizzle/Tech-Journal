#!/bin/bash
# DNSresolver.sh 10.0.5 10.0.5.22
# This tool takes a network prefix and a specific DNS server and performs a network lookup on all the addresses in the /24 network

IPprefix=$1
DNSserver=$2

for i in {1..255}; do
  ip="${IPprefix}.${i}"
  nslookup $ip $DNSserver | grep "name"
done
