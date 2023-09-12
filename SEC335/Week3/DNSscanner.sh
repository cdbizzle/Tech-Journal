#!/bin/bash
# DNSscanner.sh 10.0.5 53
# This tool is used to scan a specified port on the devices of a /24 network 

IPprefix=$1
port=$2
echo -e "IP range being checked: $IPprefix.0/24\n- - - - - - - - - - - - - - - - - - -"
echo -e "Port being checked: $port\n- - - - - - - - - - - - - - - - - - -"
echo -e "Results:"
for i in {1..255}; do
  ip="${IPprefix}.${i}"
  timeout .1 bash -c "echo >/dev/tcp/$ip/$port" 2>/dev/null &&
  echo "$ip, port $port is open"
done
