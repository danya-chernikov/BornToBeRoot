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
echo "#Network: IP "
echo "#Sudo : $(sudo ls /var/log/sudo | wc -l) cmd"
