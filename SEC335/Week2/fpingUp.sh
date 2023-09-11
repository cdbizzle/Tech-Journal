#!/bin/bash
# This script will use fping to send one ping to a sequence of IPs and then return if they are online or not. Output will be written to sweep1.txt.
sudo fping -s -g 10.0.5.2 10.0.5.50 2>/dev/null | grep "is alive" | cut -d ' ' -f 1 >> sweep1.txt