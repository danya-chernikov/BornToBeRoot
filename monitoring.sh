#!/bin/bash

echo "#Architecture: $(uname -a)"

echo "#CPU physical : "

echo "#vCPU : "

echo "#Memory Usage: "

echo "#Disk Usage: "

echo "#CPU load: "

echo "#Last boot: $(who -b)"

echo "#LVM use: $(if [ -z "$(cat /etc/fstab | grep -m 1 'mapper')" ]; then echo 'no'; else echo 'yes'; fi)"

echo "#TCP Connections : $(ss -t state established | grep -v 'Recv-Q' | wc -l)"

echo "#User log: $(who | wc -l)"

echo "#Network:"

# Trying to determine all network interfaces present in the server and their IP and MAC addresses
ip address | while IFS= read -r line
do
	if [[ "$line" =~ (^[0-9]{1,6}:[[:space:]]+)(eth[0-9]{1,5}|enp[0-9]{1,3}s[0-9]{1,2}|wlan[0-9]{1,5}|wlp[0-9]{1,3}s[0-9]{1,2}|(wwan|tun|wg|ppp|tap|veth|macvtap|macvlan|bridge|br|bond)[0-9]{1,5}) ]]; then
		interface="${BASH_REMATCH[2]}"
		IFS= read -r line
		if [[ "$line" =~ (.*[[:space:]]+link.ether[[:space:]]+)([a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}) ]]; then
			mac="${BASH_REMATCH[2]}"	
			IFS= read -r line
			if [[ "$line" =~ (.*[[:space:]]+inet )([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}) ]]; then
				ip="${BASH_REMATCH[2]}"
				echo -e "\t$interface => [$ip : $mac]"
			fi
		fi
	fi
done

# Also it makes sence to get our external IP address
web_cnt=$(wget https://showmyip.com -q -O -)

ext_ip=$(echo "$web_cnt" | grep -oE '(<h2[[:space:]]+id[[:space:]]?=[[:space:]]?"ipv4">)([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})')
if [[ -n "$ext_ip" ]]; then
	ext_ip=$(echo "$ext_ip" | sed 's/<h2 id="ipv4">//g')
	echo -e "\tExternal IP: $ext_ip"
fi

echo "#Sudo : $(sudo ls /var/log/sudo | wc -l) cmd"
