# harbor



## 初始化节点



```
hostnamectl set-hostname registry.myk8s.example.com

nmcli con mod ens160 ipv4.addresses 192.168.26.100/24
nmcli con mod ens160 ipv4.gateway 192.168.26.2
nmcli con mod ens160 ipv4.method manual
nmcli con mod ens160 ipv4.dns "192.168.26.2"
nmcli con up ens160

cat <<EOF>> /etc/hosts
192.168.26.100 registry.myk8s.example.com
EOF

setenforce 0
sudo sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config

firewall-cmd --permanent --add-port=443/tcp
firewall-cmd --reload

```





## 安装docker和docker-compose

```


## 安装docker-compose 
curl -LO https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-linux-x86_64

mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose
chmod a+x /usr/local/bin/docker-compose

```





## 安装harbor

```

mkdir -p /opt/certs

cd /opt/certs

CNAME_CA=ca.myk8s.example.com
CER_ROOT_CA=myrootCA

openssl genrsa -out ${CER_ROOT_CA}.key 4096

openssl req -x509 -new -nodes -sha512 -days 3650 \
 -subj "/C=CN/ST=Shenzhen/L=Shenzhen/O=Company/OU=GPS/CN=${CNAME_CA}" \
 -key ${CER_ROOT_CA}.key \
 -out ${CER_ROOT_CA}.crt

CER_NAME=registry.myk8s.example.com

openssl genrsa -out ${CER_NAME}.key 4096

openssl req -sha512 -new \
    -subj "/C=CN/ST=Shenzhen/L=Shenzhen/O=Company/OU=GPS/CN=${CER_NAME}" \
    -key ${CER_NAME}.key \
-out ${CER_NAME}.csr

cat > harbor.cnf << EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = registry.myk8s.example.com
DNS.2 = registry
EOF

openssl x509 -req -in ${CER_NAME}.csr -CA ${CER_ROOT_CA}.crt \
   -CAkey ${CER_ROOT_CA}.key -CAcreateserial -out ${CER_NAME}.crt \
   -days 3650 -extensions v3_req -extfile harbor.cnf

添加信任证书
cp /opt/certs/myrootCA.crt /etc/pki/ca-trust/source/anchors/
update-ca-trust



cd /opt/harbor
cp harbor.yml.tmpl harbor.yml

修改主机名、端口和证书
vim harbor.yml

hostname: registry.myk8s.example.com

http:
  port: 5080

https:
  port: 5000
  certificate: /opt/certs/registry.myk8s.example.com.crt
  private_key: /opt/certs/registry.myk8s.example.com.key



./install.sh --with-notary --with-trivy --with-chartmuseum



curl -u admin:Harbor12345 -k https://registry.myk8s.example.com/v2/_catalog 

docker login -u admin -p Harbor12345 https://registry.myk8s.ocp.com


scp root@192.168.2.247:/opt/certs/myrootCA.crt /root/myrootCA.crt



```

### 为harbor 设置系统服务

```
vim /lib/systemd/system/harbor.service


[Unit]
Description=Harbor
After=docker.service systemd-networkd.service systemd-resolved.service
Requires=docker.service
Documentation=http://github.com/vmware/harbor

[Service]
Type=simple
Restart=on-failure
RestartSec=5
ExecStart=/usr/local/bin/docker-compose -f  /root/harbor/docker-compose.yml up
ExecStop=/usr/local/bin/docker-compose -f /root/harbor/docker-compose.yml down

[Install]
WantedBy=multi-user.target
```





## 同步所需要的镜像











# 配置离线yum 源 

## docker-ce 源

```
for repo in \
appstream \
baseos \
docker-ce-stable
do
  reposync -p /opt/repos --download-metadata --repo=${repo} -n --delete
done


```







## kubernetes 源



