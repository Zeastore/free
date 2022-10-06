#!/bin/bash
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
#########################

clear
red='\e[1;31m'
green='\e[0;32m'
yell='\e[1;33m'
NC='\e[0m'
echo "XRAY Core Vmess / Vless"
echo "Trojan"
echo "Progress..."
sleep 3
green() { echo -e "\\033[32;1m${*}\\033[0m"; }
red() { echo -e "\\033[31;1m${*}\\033[0m"; }
echo -e ""
date
echo ""
domain=$(cat /root/domain)
sleep 1
mkdir -p /etc/xray 
echo -e "[ ${green}INFO${NC} ] Checking... "
apt install iptables iptables-persistent -y
sleep 1
echo -e "[ ${green}INFO$NC ] Setting ntpdate"
ntpdate pool.ntp.org 
timedatectl set-ntp true
sleep 1
echo -e "[ ${green}INFO$NC ] Enable chronyd"
systemctl enable chronyd
systemctl restart chronyd
sleep 1
echo -e "[ ${green}INFO$NC ] Enable chrony"
systemctl enable chrony
systemctl restart chrony
timedatectl set-timezone Asia/Jakarta
sleep 1
echo -e "[ ${green}INFO$NC ] Setting chrony tracking"
chronyc sourcestats -v
chronyc tracking -v
echo -e "[ ${green}INFO$NC ] Setting dll"
apt clean all && apt update
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion ntpdate -y
ntpdate pool.ntp.org
apt -y install chrony
apt install zip -y
apt install curl pwgen openssl netcat cron -y

# install xray
sleep 1
echo -e "[ ${green}INFO$NC ] Downloading & Installing xray core"
domainSock_dir="/run/xray";! [ -d $domainSock_dir ] && mkdir  $domainSock_dir
chown www-data.www-data $domainSock_dir
# Make Folder XRay
mkdir -p /var/log/xray
mkdir -p /etc/xray
chown www-data.www-data /var/log/xray
chmod +x /var/log/xray
touch /var/log/xray/access.log
touch /var/log/xray/error.log
touch /var/log/xray/access2.log
touch /var/log/xray/error2.log

# / / Ambil Xray Core Version Terbaru
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version 1.5.6

##Generate acme certificate
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

# nginx renew ssl
echo -n '#!/bin/bash
/etc/init.d/nginx stop
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
/etc/init.d/nginx start
' > /usr/local/bin/ssl_renew.sh
chmod +x /usr/local/bin/ssl_renew.sh
if ! grep -q 'ssl_renew.sh' /var/spool/cron/crontabs/root;then (crontab -l;echo "15 03 */3 * * /usr/local/bin/ssl_renew.sh") | crontab;fi

mkdir -p /home/vps/public_html

# set uuid
uuid=$(cat /proc/sys/kernel/random/uuid)
# xray config

#!/bin/bash
echo -e "
"
date
echo ""
domain=$(cat /root/domain)
sleep 1
mkdir -p /etc/xray 
echo -e "[ ${green}INFO${NC} ] Checking... "
apt install iptables iptables-persistent -y
sleep 1
echo -e "[ ${green}INFO$NC ] Setting ntpdate"
ntpdate pool.ntp.org 
timedatectl set-ntp true
sleep 1
echo -e "[ ${green}INFO$NC ] Enable chronyd"
systemctl enable chronyd
systemctl restart chronyd
sleep 1
echo -e "[ ${green}INFO$NC ] Enable chrony"
systemctl enable chrony
systemctl restart chrony
timedatectl set-timezone Asia/Jakarta
sleep 1
echo -e "[ ${green}INFO$NC ] Setting chrony tracking"
chronyc sourcestats -v
chronyc tracking -v
echo -e "[ ${green}INFO$NC ] Setting dll"
apt clean all && apt update
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion ntpdate -y
ntpdate pool.ntp.org
apt -y install chrony
apt install zip -y
apt install curl pwgen openssl netcat cron -y


# install xray
sleep 1
echo -e "[ ${green}INFO$NC ] Downloading & Installing xray core"
domainSock_dir="/run/xray";! [ -d $domainSock_dir ] && mkdir  $domainSock_dir
chown www-data.www-data $domainSock_dir
# Make Folder XRay
mkdir -p /var/log/xray
mkdir -p /etc/xray
chown www-data.www-data /var/log/xray
chmod +x /var/log/xray
touch /var/log/xray/access.log
touch /var/log/xray/error.log
touch /var/log/xray/access2.log
touch /var/log/xray/error2.log
# / / Ambil Xray Core Version Terbaru
bash -c "$(curl -L https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install -u www-data --version 1.5.6



## crt xray
systemctl stop nginx
mkdir /root/.acme.sh
curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc

# nginx renew ssl
echo -n '#!/bin/bash
/etc/init.d/nginx stop
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
/etc/init.d/nginx start
/etc/init.d/nginx status
' > /usr/local/bin/ssl_renew.sh
chmod +x /usr/local/bin/ssl_renew.sh
if ! grep -q 'ssl_renew.sh' /var/spool/cron/crontabs/root;then (crontab -l;echo "15 03 */3 * * /usr/local/bin/ssl_renew.sh") | crontab;fi

mkdir -p /home/vps/public_html

# KONFIRUGASI NGINX
echo '
    server {
             listen 80;
             listen [::]:80;
             listen 443 ssl http2 reuseport;
             listen [::]:443 http2 reuseport;	
             server_name 127.0.0.1 localhost;
             ssl_certificate /etc/syn/xray.crt;
             ssl_certificate_key /etc/syn/xray.key;
             ssl_ciphers EECDH+CHACHA20:EECDH+CHACHA20-draft:EECDH+ECDSA+AES128:EECDH+aRSA+AES128:RSA+AES128:EECDH+ECDSA+AES256:EECDH+aRSA+AES256:RSA+AES256:EECDH+ECDSA+3DES:EECDH+aRSA+3DES:RSA+3DES:!MD5;
             ssl_protocols TLSv1.1 TLSv1.2 TLSv1.3;
             
location /
{
proxy_redirect off;
proxy_pass http://127.0.0.1:2083;
proxy_http_version 1.1;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_set_header Host $http_host;
}
location = /vless-ws
{
proxy_redirect off;
proxy_pass http://127.0.0.1:37466;
proxy_http_version 1.1;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_set_header Host $http_host;
}
location = /vmess-ws
{
proxy_redirect off;
proxy_pass http://127.0.0.1:34860;
proxy_http_version 1.1;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_set_header Host $http_host;
}
location = /trojan-ws
{
proxy_redirect off;
proxy_pass http://127.0.0.1:16742;
proxy_http_version 1.1;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_set_header Host $http_host;
}
location = /ss-ws
{
proxy_redirect off;
proxy_pass http://127.0.0.1:14963;
proxy_http_version 1.1;
proxy_set_header X-Real-IP $remote_addr;
proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_set_header Host $http_host;
}
location ^~ /vless-grpc
{
proxy_redirect off;
grpc_set_header X-Real-IP $remote_addr;
grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
grpc_set_header Host $http_host;
grpc_pass grpc://127.0.0.1:42141;
}
location ^~ /vmess-grpc
{
proxy_redirect off;
grpc_set_header X-Real-IP $remote_addr;
grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
grpc_set_header Host $http_host;
grpc_pass grpc://127.0.0.1:40228;
}
location ^~ /trojan-grpc
{
proxy_redirect off;
grpc_set_header X-Real-IP $remote_addr;
grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
grpc_set_header Host $http_host;
grpc_pass grpc://127.0.0.1:28555;
}
location ^~ /ss-grpc
{
proxy_redirect off;
grpc_set_header X-Real-IP $remote_addr;
grpc_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
grpc_set_header Host $http_host;
grpc_pass grpc://127.0.0.1:36193;
}
        }

' > /etc/nginx/conf.d/xray.conf

# set uuid
uuid=$(cat /proc/sys/kernel/random/uuid)
# xray config
cat > /etc/xray/config.json << END
# KONFIRUGASI XRAY LANJUTAN (JSON)
echo '
{
    "log" : {
      "access": "/var/log/xray/access.log",
      "error": "/var/log/xray/error.log",
      "loglevel": "warning"
    },
    "inbounds": [
        {
        "listen": "127.0.0.1",
        "port": 10085,
        "protocol": "dokodemo-door",
        "settings": {
          "address": "127.0.0.1"
        },
        "tag": "api"
      },
     {
       "listen": "127.0.0.1",
        "port": "37466",
        "protocol": "vless",
        "settings": {
            "decryption":"none",
              "clients": [
                 {
                   "id": "1149e787-a203-4798-9900-d850acde7588"                 
  #vlessws
               }
            ]
         },
         "streamSettings":{
           "network": "ws",
              "wsSettings": {
                  "path": "/vless-ws"
            }
          }
       },
       {
       "listen": "127.0.0.1",
       "port": "34860",
       "protocol": "vmess",
        "settings": {
              "clients": [
                 {
                   "id": "1149e787-a203-4798-9900-d850acde7588",
                   "alterId": 0
  #vmessws
               }
            ]
         },
         "streamSettings":{
           "network": "ws",
              "wsSettings": {
                  "path": "/vmess-ws"
            }
          }
       },
      {
        "listen": "127.0.0.1",
        "port": "16742",
        "protocol": "trojan",
        "settings": {
            "decryption":"none",		
             "clients": [
                {
                   "password": "1149e787-a203-4798-9900-d850acde7588"
  #trojanws
                }
            ],
           "udp": true
         },
         "streamSettings":{
             "network": "ws",
             "wsSettings": {
                 "path": "/trojan-ws"
              }
           }
       },
       {
          "listen": "127.0.0.1",
          "port": "37790",
          "protocol": "socks",
          "settings": {
            "auth": "password",
               "accounts": [
            {
                   "user": "biji",
                   "pass": "peler"
  #socksws
             }
            ],
           "level": 0,
            "udp": true
         },
         "streamSettings":{
            "network": "ws",
               "wsSettings": {
                 "path": "/socks-ws"
             }
          }
       },	
       {
        "listen": "127.0.0.1",
        "port": "14963",
            "protocol": "shadowsocks",
            "settings": {
                "decryption":"none",
                "clients": [
                    {
                        "password": "a9d7a78b-1691-483c-af19-05660899d358",
                        "method": "AES-128-GCM",
                        "ivCheck": false,
                        "level": 0,
                        "email": "admin"
#shadowsocksws
                    }
                            ],
                        "network": "tcp,udp"
                    },
                    "streamSettings":{
                "network": "ws",
                "wsSettings": {
                    "path": "/ss-ws"
                }
            }
        },	
        {
          "listen": "127.0.0.1",
          "port": "42141",
          "protocol": "vless",
          "settings": {
           "decryption":"none",
             "clients": [
               {
                 "id": "1149e787-a203-4798-9900-d850acde7588"
  #vlessgrpc
               }
            ]
         },
            "streamSettings":{
               "network": "grpc",
               "grpcSettings": {
                  "serviceName": "vless-grpc"
             }
          }
       },
       {
        "listen": "127.0.0.1",
       "port": "40228",
       "protocol": "vmess",
        "settings": {
              "clients": [
                 {
                   "id": "1149e787-a203-4798-9900-d850acde7588",
                   "alterId": 0
  #vmessgrpc
               }
            ]
         },
         "streamSettings":{
           "network": "grpc",
              "grpcSettings": {
                  "serviceName": "vmess-grpc"
            }
          }
       },
       {
          "listen": "127.0.0.1",
          "port": "28555",
          "protocol": "trojan",
          "settings": {
            "decryption":"none",
               "clients": [
                 {
                   "password": "1149e787-a203-4798-9900-d850acde7588"
  #trojangrpc
                 }
             ]
          },
           "streamSettings":{
           "network": "grpc",
             "grpcSettings": {
                 "serviceName": "trojan-grpc"
           }
        }
    },
    {
          "listen": "127.0.0.1",
          "port": "39583",
          "protocol": "socks",
          "settings": {
            "auth": "password",
               "accounts": [
            {
                   "user": "biji",
                   "pass": "peler"
  #socksgrpc
             }
            ],
           "level": 0,
            "udp": true
         },
         "streamSettings":{
            "network": "grpc",
               "grpcSettings": {
                 "serviceName": "socks-grpc"
             }
          }
       },
     {
		"listen": "127.0.0.1",
		"port": "36193",
		"protocol": "shadowsocks",
        "settings": {
            "decryption":"none",
            "clients": [
                {
                    "password": "a9d7a78b-1691-483c-af19-05660899d358",
                    "method": "AES-128-GCM",
                    "ivCheck": false,
                    "level": 0,
                    "email": "admin"
#shadowsocksgrpc
                }
                        ],
                    "network": "tcp,udp"
                },
                "streamSettings":{

		"network": "grpc",
			"grpcSettings": {
				"serviceName": "ss-grpc"
			}
		}
	}	
    ],
    "outbounds": [
      {
        "protocol": "freedom",
        "settings": {}
      },
      {
        "protocol": "blackhole",
        "settings": {},
        "tag": "blocked"
      }
    ],
    "routing": {
      "rules": [
        {
          "type": "field",
          "ip": [
            "0.0.0.0/8",
            "10.0.0.0/8",
            "100.64.0.0/10",
            "169.254.0.0/16",
            "172.16.0.0/12",
            "192.0.0.0/24",
            "192.0.2.0/24",
            "192.168.0.0/16",
            "198.18.0.0/15",
            "198.51.100.0/24",
            "203.0.113.0/24",
            "::1/128",
            "fc00::/7",
            "fe80::/10"
          ],
          "outboundTag": "blocked"
        },
        {
          "inboundTag": [
            "api"
          ],
          "outboundTag": "api",
          "type": "field"
        },
        {
          "type": "field",
          "outboundTag": "blocked",
          "protocol": [
            "bittorrent"
          ]
        }
      ]
    },
    "stats": {},
    "api": {
      "services": [
        "StatsService"
      ],
      "tag": "api"
    },
    "policy": {
      "levels": {
        "0": {
          "statsUserDownlink": true,
          "statsUserUplink": true
        }
      },
      "system": {
        "statsInboundUplink": true,
        "statsInboundDownlink": true,
        "statsOutboundUplink" : true,
        "statsOutboundDownlink" : true
      }
    }
  }
' > /usr/local/etc/xray/config.json
# NONE TLS
echo '
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
    },
    "inbounds": [
    {
      "port": 80,
      "protocol": "vmess",
      "settings": {
        "clients": [
          {
            "id": "a9d7a78b-1691-483c-af19-05660899d358",
            "level": 0,
            "email": "admin"
#vmessws
          }
        ]
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "tlsSettings": {},
        "tcpSettings": {},
        "kcpSettings": {},
        "httpSettings": {},
        "wsSettings": {
          "path": "/vmess-ws",
          "headers": {
            "Host": ""
          }
        },
        "quicSettings": {}
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    },
    {
      "port": 80,
      "protocol": "vless",
      "settings": {
        "clients": [
          {
            "id": "a9d7a78b-1691-483c-af19-05660899d358",
            "level": 0,
            "email": "admin"
#vlessws
          }
        ],
        "decryption": "none"
      },
      "streamSettings": {
        "network": "ws",
        "security": "none",
        "tlsSettings": {},
        "tcpSettings": {},
        "kcpSettings": {},
        "httpSettings": {},
        "wsSettings": {
          "path": "/vless-ws",
          "headers": {
            "Host": ""
          }
        },
        "quicSettings": {}
      },
      "sniffing": {
        "enabled": true,
        "destOverride": [
          "http",
          "tls"
        ]
      }
    }
    ],
    "outbounds": [
        {
            "protocol": "freedom"
        }
    ]
}
' > /usr/local/etc/xray/none.json

END
rm -rf /etc/systemd/system/xray.service.d
cat <<EOF> /etc/systemd/system/xray.service
Description=Xray Service
Documentation=https://github.com/xtls
After=network.target nss-lookup.target

[Service]
User=www-data
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE                                 AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23
LimitNPROC=10000
LimitNOFILE=1000000
[Install]
WantedBy=multi-user.target
EOF
cat > /etc/systemd/system/runn.service <<EOF
[Unit]
Description=Mampus-Anjeng
After=network.target
[Service]
Type=simple
ExecStartPre=-/usr/bin/mkdir -p /var/run/xray
ExecStart=/usr/bin/chown www-data:www-data /var/run/xray
Restart=on-abort
[Install]
WantedBy=multi-user.target

sed -i '$ ilocation = /vless' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://unix:/run/xray/vless_ws.sock;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sed -i '$ ilocation = /vmess' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://unix:/run/xray/vmess_ws.sock;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sed -i '$ ilocation = /trojan-ws' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://unix:/run/xray/trojan_ws.sock;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sed -i '$ ilocation = /ss-ws' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:30300;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sed -i '$ ilocation /' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_pass http://127.0.0.1:700;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_http_version 1.1;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Upgrade \$http_upgrade;' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Connection "upgrade";' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sed -i '$ ilocation ^~ /vless-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://unix:/run/xray/vless_grpc.sock;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sed -i '$ ilocation ^~ /vmess-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://unix:/run/xray/vmess_grpc.sock;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sed -i '$ ilocation ^~ /trojan-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://unix:/run/xray/trojan_grpc.sock;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sed -i '$ ilocation ^~ /ss-grpc' /etc/nginx/conf.d/xray.conf
sed -i '$ i{' /etc/nginx/conf.d/xray.conf
sed -i '$ iproxy_redirect off;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Real-IP \$remote_addr;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_set_header Host \$http_host;' /etc/nginx/conf.d/xray.conf
sed -i '$ igrpc_pass grpc://127.0.0.1:30310;' /etc/nginx/conf.d/xray.conf
sed -i '$ i}' /etc/nginx/conf.d/xray.conf
sleep 1
echo -e "[ ${green}INFO$NC ] Installing bbr.."
#wget -q -O /usr/bin/bbr "https://raw.githubusercontent.com/Zeastore/free/main/dll/bbr.sh"
#chmod +x /usr/bin/bbr
#bbr >/dev/null 2>&1
#rm /usr/bin/bbr >/dev/null 2>&1
echo -e "$yell[SERVICE]$NC Restart All service"
systemctl daemon-reload
sleep 1
echo -e "[ ${green}ok${NC} ] Enable & restart xray "
systemctl enable xray
systemctl restart xray
systemctl restart nginx
systemctl enable runn
systemctl restart runn
sleep 1
#wget -O usernew "https://raw.githubusercontent.com/Zeastore/free/main/ssh/usernew.sh"
wget -O add-ws "https://raw.githubusercontent.com/Zeastore/free/main/xray/add-ws.sh"
wget -O add-vless "https://raw.githubusercontent.com/Zeastore/free/main/xray/add-vless.sh"
wget -O add-tr "https://raw.githubusercontent.com/Zeastore/free/main/xray/add-tr.sh"
wget -O del-user "https://raw.githubusercontent.com/Zeastore/free/main/xray/del-ws.sh"
wget -O cek-user "https://raw.githubusercontent.com/Zeastore/free/main/xray/cek-ws.sh"
wget -O renew-user "https://raw.githubusercontent.com/Zeastore/free/main/xray/renew-ws.sh"
wget -O crtv2ray "https://raw.githubusercontent.com/Zeastore/free/main/xray/cert.sh"
wget -O add-ssws "https://raw.githubusercontent.com/Zeastore/free/main/xray/add-ssws.sh"
  chmod +x add-ws
  chnod +x add-vless
  chmod +x add-tr
  chmod +x del-user
  chmod +x cek-user
  chmod +x renew-user
  chmod +x crtv2ray
  chmod +x add-ssws
sleep 1
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
yellow "xray/Vmess"
yellow "xray/Vless"
mv /root/domain /etc/xray/ 
if [ -f /root/scdomain ];then
rm /root/scdomain > /dev/null 2>&1
fi
clear
rm -f ins-xray.sh
