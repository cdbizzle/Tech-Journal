#!/bin/bash
# This script will use nmap to scan a range of IPs and then return if they are online or not. Output will be written to sweep2.txt.
sudo nmap -n -sn 10.0.5.2-50 | grep -o -E "([0-9]{1,3}[\.]){3}[0-9]{1,3}" >> sweep3.txt