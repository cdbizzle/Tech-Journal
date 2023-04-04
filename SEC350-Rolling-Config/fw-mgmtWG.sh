source /opt/vyatta/etc/functions/script-template
set firewall name LAN-to-MGMT rule 35 action accept
set firewall name LAN-to-MGMT rule 35 description "Allow RDP traffic to MGMT02 from Wireguard"
set firewall name LAN-to-MGMT rule 35 destination address 172.16.200.11
set firewall name LAN-to-MGMT rule 35 destination port 3389
set firewall name LAN-to-MGMT rule 35 protocol tcp 
set firewall name LAN-to-MGMT rule 35 source address 10.1.0.2
commit
save
