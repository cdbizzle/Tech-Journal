#!bin/bash
# This script will send one ping to a sequence of IPs 10.0.5.2 through 10.0.5.50 and only print out the IPs that are online. The output will be written to sweep.txt.
for ip in $(seq 2 50); do
ping -c 1 10.0.5.$ip | grep "64 bytes" | cut -d " " -f 4 | cut -d ":" -f 1 >> sweep.txt
done
