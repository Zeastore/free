#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################


cd
MYIP=$(curl -sS ipv4.icanhazip.com)
NameUser=$(curl -sS | grep $MYIP | awk '{print $2}')

cekdata=$(curl -sS https://raw.githubusercontent.com/bokir-tampan/userbackup/main/$NameUser/$NameUser.zip | grep 404 | awk '{print $1}' | cut -d: -f1)

[[ "$cekdata" = "404" ]] && {
red "Data not found / you never backup"
exit 0
} || {
green "Data found for username $NameUser"
}

echo -e "[ ${green}INFO${NC} ] • Restore Data..."
read -rp "Password File: " -e InputPass
echo -e "[ ${green}INFO${NC} ] • Downloading data.."
wget -q -O /root/backup/backup.zip "https://raw.githubusercontent.com/bokir-tampan/userbackup/main/$NameUser/$NameUser.zip" &> /dev/null
echo -e "[ ${green}INFO${NC} ] • Getting your data..."
unzip -P $InputPass /root/backup/backup.zip &> /dev/null
echo -e "[ ${green}INFO${NC} ] • Starting to restore data..."
rm -f /root/backup/backup.zip &> /dev/null
sleep 1
cd /root/backup
echo -e "[ ${green}INFO${NC} ] • Restoring passwd data..."
sleep 1
cp /root/backup/passwd /etc/ &> /dev/null
echo -e "[ ${green}INFO${NC} ] • Restoring group data..."
sleep 1
cp /root/backup/group /etc/ &> /dev/null
echo -e "[ ${green}INFO${NC} ] • Restoring shadow data..."
sleep 1
cp /root/backup/shadow /etc/ &> /dev/null
echo -e "[ ${green}INFO${NC} ] • Restoring gshadow data..."
sleep 1
cp /root/backup/gshadow /etc/ &> /dev/null
echo -e "[ ${green}INFO${NC} ] • Restoring chap-secrets data..."
sleep 1
cp /root/backup/chap-secrets /etc/ppp/ &> /dev/null
echo -e "[ ${green}INFO${NC} ] • Restoring passwd1 data..."
sleep 1
cp /root/backup/passwd1 /etc/ipsec.d/passwd &> /dev/null
echo -e "[ ${green}INFO${NC} ] • Restoring ss.conf data..."
sleep 1
cp /root/backup/ss.conf /etc/shadowsocks-libev/ss.conf &> /dev/null
echo -e "[ ${green}INFO${NC} ] • Restoring admin data..."
sleep 1
cp -r /root/backup/scrz-prem /var/lib/ &> /dev/null
cp -r /root/backup/wireguard /etc/ &> /dev/null
cp -r /root/backup/.acme.sh /root/ &> /dev/null
cp -r /root/backup/sstp /home/ &> /dev/null
cp -r /root/backup/trojan-go /etc/ &> /dev/null
cp -r /root/backup/v2ray /etc/ &> /dev/null
cp -r /root/backup/xray /etc/ &> /dev/null
cp -r /root/backup/shadowsocksr /usr/local/ &> /dev/null
cp -r /root/backup/public_html /home/vps/ &> /dev/null
cp /root/backup/crontab /etc/ &> /dev/null
cp -r /root/backup/cron.d /etc/ &> /dev/null
rm -rf /root/backup &> /dev/null
echo -e "[ ${green}INFO${NC} ] • Done..."
sleep 1
rm -f /root/backup/backup.zip &> /dev/null
echo 
read -n 1 -s -r -p "Press any key to back on menu"
system-menu
