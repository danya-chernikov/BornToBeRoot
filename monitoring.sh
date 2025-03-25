#!/bin/bash

echo "#OS architecture: $(uname -m 2> /dev/null)"

echo "#Kernel version: $(uname -r 2> /dev/null)"

echo "#CPU physical: $(lscpu 2> /dev/null | grep -oE 'Core\(s\) per socket:[[:space:]]*[0-9]+' 2> /dev/null | grep -oE '[0-9]+' 2> /dev/null)"

echo "#vCPU: $(lscpu 2> /dev/null | grep -Eo '^CPU\(s\):[[:space:]]*[0-9]+' 2> /dev/null | grep -Eo '[0-9]+' 2> /dev/null)"

# Let's evaluate the memory usage
mem_total=$(cat /proc/meminfo 2> /dev/null | grep -oE 'MemTotal:[[:space:]]*[0-9]+[[:space:]]*kB' 2> /dev/null | grep -oE '[0-9]+' 2> /dev/null)
mem_avail=$(cat /proc/meminfo 2> /dev/null | grep -oE 'MemAvailable:[[:space:]]*[0-9]+[[:space:]]*kB' 2> /dev/null | grep -oE '[0-9]+' 2> /dev/null)
mem_occup=$((mem_total/1024 - mem_avail/1024))
mem_usage_percent=$((100 - mem_avail*100/mem_total))

echo "#Memory usage: "$mem_occup"/"$((mem_total/1024))"MB ($mem_usage_percent%)"

# Let's evaluate the disk usage space
root_part=$(df -h -BM 2> /dev/null | grep -oE '^/dev/.+/$' 2> /dev/null)
disk_size=$(echo $root_part | awk '{print $2}' 2> /dev/null | grep -oE '[0-9]+' 2> /dev/null)
disk_used=$(echo $root_part | awk '{print $3}' 2> /dev/null | grep -oE '[0-9]+' 2> /dev/null)
disk_usage_percent=$((disk_used*100/disk_size))

echo "#Disk usage: "$disk_used"MB/$((disk_size/1024))GB ($disk_usage_percent%)"

#cpu_idle=$(iostat -c | grep -A 1 user | grep -v user | awk '{print $6}')
#cpu_idle_percent=$(echo "scale=2; 100.0 - $cpu_idle" | bc)
#echo "#CPU load: $((100 - cpu_idle))%"
echo "#CPU load: "$[100-$(vmstat 1 2|tail -1|awk '{print $15}')]"%"

echo "#Last boot: $(who -b 2> /dev/null | grep -oE '[0-9]{4}-[0-9]{2}-[0-9]{2}[[:space:]]+[0-9]{2}:[0-9]{2}' 2> /dev/null)"

echo "#LVM use: $(if [ -z "$(df -h 2> /dev/null | grep -m 1 'mapper' 2> /dev/null)" ]; then echo 'no'; else echo 'yes'; fi)"

echo "#TCP connections: $(ss -t state established 2> /dev/null | grep -v 'Recv-Q' 2> /dev/null | wc -l 2> /dev/null)"

echo "#User log: $(who 2> /dev/null | wc -l 2> /dev/null)"

echo "#Sudo: $(ls /var/log/sudo 2> /dev/null | wc -l 2> /dev/null) cmd"

echo -n "#Network: "

# Also it makes sense to get our external IP address
web_cnt=$(wget https://showmyip.com -q -O - 2> /dev/null)

ext_ip=$(echo "$web_cnt" | grep -oE '(<h2[[:space:]]+id[[:space:]]?=[[:space:]]?"ipv4">)([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3})' 2> /dev/null)
if [[ -n "$ext_ip" ]]; then
	ext_ip=$(echo "$ext_ip" | sed 's/<h2 id="ipv4">//g' 2> /dev/null)
	echo -n "external IP: $ext_ip | "
fi

# Trying to determine all network interfaces present on the server and their IP and MAC addresses
ip address 2> /dev/null | while IFS= read -r line
do
	if [[ "$line" =~ (^[0-9]{1,6}:[[:space:]]+)(eth[0-9]{1,5}|enp[0-9]{1,3}s[0-9]{1,2}|wlan[0-9]{1,5}|wlp[0-9]{1,3}s[0-9]{1,2}|(wwan|tun|wg|ppp|tap|veth|macvtap|macvlan|bridge|br|bond)[0-9]{1,5}) ]]; then
		interface="${BASH_REMATCH[2]}"
		IFS= read -r line
		if [[ "$line" =~ (.*[[:space:]]+link.ether[[:space:]]+)([a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}:[a-fA-F0-9]{2}) ]]; then
			mac="${BASH_REMATCH[2]}"	
			IFS= read -r line
			if [[ "$line" =~ (.*[[:space:]]+inet )([0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}) ]]; then
				ip="${BASH_REMATCH[2]}"
				echo "$interface => [$ip : $mac]"
			fi
		fi
	fi
done

exit
