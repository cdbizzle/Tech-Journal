#!/bin/bash

hostfile=$1
portfile=$2
echo -e "IPs being checked:\n$(cat "$hostfile")\n- - - - - - - - - - - - - - - - - - -"
echo -e "Ports being checked:\n$(cat "$portfile")\n- - - - - - - - - - - - - - - - - - -"
echo -e "Results:"
for host in $(cat $hostfile); do
  for port in $(cat $portfile); do
    timeout .1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null &&
      echo "$host, port $port is open"
  done
done