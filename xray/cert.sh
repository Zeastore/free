#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################
curl https://get.acme.sh | sh
alias acme.sh=~/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
#/root/.acme.sh/acme.sh --issue -d "${domain}" --standalone --keylength ec-2048
/root/.acme.sh/acme.sh --issue -d "${domain}" --standalone --keylength ec-256
/root/.acme.sh/acme.sh --install-cert -d "${domain}" --ecc \
--fullchain-file /etc/xray/xray.crt \
--key-file /etc/xray/xray.key
chown -R nobody:nogroup /etc/xray
chmod 644 /etc/xray/xray.crt
chmod 644 /etc/xray/xray.key

echo ""
read -n 1 -s -r -p "Press any key to back on menu"
menu
