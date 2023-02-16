source /opt/vyatta/etc/functions/script-template
run show configuration commands | grep -v "syslog global\|ntp\|login\|console\|config\|hw-id\|loopback\|conntrack" > config-commands.txt
sections=( interface system protocols service zone firewall )
for section in "${sections[@]}"
do
	echo "## $section"
        echo '<pre>'
	echo "$(cat 'config-commands.txt' | grep "set $section")"
        echo "</pre>"
done
