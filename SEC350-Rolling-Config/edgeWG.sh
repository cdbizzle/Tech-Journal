source /opt/vyatta/etc/functions/script-template
set interfaces wireguard wg0 address 10.1.0.1/24
set interfaces wireguard wg0 description 'Wireguard interface for tunnel'
set interfaces wireguard wg0 peer traveler-cole allowed-ips 10.1.0.2/32
set interfaces wireguard wg0 peer traveler-cole public-key D/2ZrgfoznwVM10ecuFIll1Y166cl7rfgFSmMjtB9w0=
set interfaces wireguard wg0 port 51820
run generate pki wireguard key-pair install interface wg0
set firewall name VPN-to-LAN default-action drop
set firewall name VPN-to-LAN enable-default-log
set firewall name VPN-to-LAN rule 10 action accept
set firewall name VPN-to-LAN rule 10 description "Allow RDP traffic to MGMT02 from Wireguard"
set firewall name VPN-to-LAN rule 10 destination address 172.16.200.11
set firewall name VPN-to-LAN rule 10 destination port 3389
set firewall name VPN-to-LAN rule 10 protocol tcp
set firewall name VPN-to-LAN rule 10 source address 10.1.0.2
set firewall name LAN-to-VPN default-action drop
set firewall name LAN-to-VPN enable-default-log
set firewall name LAN-to-VPN rule 1 action accept
set firewall name LAN-to-VPN rule 1 state established enable
set zone-policy zone LAN from VPN firewall name VPN-to-LAN
set zone-policy zone VPN from LAN firewall name LAN-to-VPN
set zone-policy zone VPN interface wg0
commit
save
