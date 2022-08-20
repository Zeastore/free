#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################


data=(`find /var/log/ -name '*.log'`);
for log in "${data[@]}"
do
echo "$log clear"
echo > $log
done
data=(`find /var/log/ -name '*.err'`);
for log in "${data[@]}"
do
echo "$log clear"
echo > $log
done
data=(`find /var/log/ -name 'mail.*'`);
for log in "${data[@]}"
do
echo "$log clear"
echo > $log
done
echo > /var/log/syslog
echo > /var/log/btmp
echo > /var/log/messages
echo > /var/log/debug

bcc=`date`
echo "Successfully clean log at $bcc"
