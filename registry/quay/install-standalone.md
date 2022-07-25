# 目标

* 在一个rhel8 节点上，以单节点的形式单独部署quay



## 准备工作



### 添加yum源

```
cat << EOF > /etc/yum.repos.d/rhel8.6.repo
[rhel-8-for-x86_64-baseos-rpms]
name=rhel-8-for-x86_64-baseos-rpms
baseurl=http://rhel8-yum.ocp.example.com/repos/rhel8.6/rhel-8-for-x86_64-baseos-rpms
enabled=1
gpgcheck=0
[rhel-8-for-x86_64-appstream-rpms]
name=rhel-8-for-x86_64-appstream-rpms
baseurl=http://rhel8-yum.ocp.example.com/repos/rhel8.6/rhel-8-for-x86_64-appstream-rpms
enabled=1
gpgcheck=0
[fast-datapath-for-rhel-8-x86_64-rpms]
name=fast-datapath-for-rhel-8-x86_64-rpms
baseurl=http://rhel8-yum.ocp.example.com/repos/rhel8.6/fast-datapath-for-rhel-8-x86_64-rpms
enabled=1
gpgcheck=0
[rhocp-4.10-for-rhel-8-x86_64-rpms]
name=rhocp-4.10-for-rhel-8-x86_64-rpms
baseurl=http://rhel8-yum.ocp.example.com/repos/rhel8.6/rhocp-4.10-for-rhel-8-x86_64-rpms
enabled=1
gpgcheck=0
EOF
```



### 安装podman

```
yum install -y podman
```



### 下载安装包

```

curl -LO https://developers.redhat.com/content-gateway/file/pub/openshift-v4/clients/mirror-registry/1.2.2/mirror-registry.tar.gz 

```



# 参数说明

## mirror-registry install



```
mirror-registry install

Flags:
      --additionalArgs string   Additional arguments you would like to append to the ansible-playbook call. Used mostly for development.
      --askBecomePass           Whether or not to ask for sudo password during SSH connection.
  -h, --help                    help for install
  -i, --image-archive string    An archive containing images
      --initPassword string     The password of the initial user. If not specified, this will be randomly generated.
      --initUser string         The username of the initial user. This defaults to init. (default "init")
      --quayHostname string     The value to set SERVER_HOSTNAME in the Quay config.yaml. This defaults to <targetHostname>:8443
  -r, --quayRoot string         The folder where quay persistent data are saved. This defaults to /etc/quay-install (default "/etc/quay-install")
  -k, --ssh-key string          The path of your ssh identity key. This defaults to ~/.ssh/quay_installer (default "/root/.ssh/quay_installer")
      --sslCert string          The path to the SSL certificate Quay should use
      --sslCheckSkip            Whether or not to check the certificate hostname against the SERVER_HOSTNAME in config.yaml.
      --sslKey string           The path to the SSL key Quay should use
  -H, --targetHostname string   The hostname of the target you wish to install Quay to. This defaults to $HOST (default "registry3.ocp.example.com")
  -u, --targetUsername string   The user on the target host which will be used for SSH. This defaults to $USER (default "root")


```





# 最简安装

## 直接安装

最简单的安装方式

```
./mirror-registry install --quayHostname $(hostname -f)
```



## 安装后计划







# 指定证书安装

## 签发新的证书

基于之前的 ca.ocp.example.com CA  为 registry3.ocp.example.com 签发证书 

```
CER_ROOT_CA=myrootCA

CER_NAME=registry3.ocp.example.com

openssl genrsa -out ${CER_NAME}.key 4096

openssl req -sha512 -new \
    -subj "/C=CN/ST=Beijing/L=Beijing/O=REDHAT/OU=GPS/CN=registry3.ocp.example.com" \
    -key ${CER_NAME}.key \
    -out ${CER_NAME}.csr

cat > registry3.cnf << EOF
[req]
req_extensions = v3_req
distinguished_name = req_distinguished_name

[req_distinguished_name]
[ v3_req ]
basicConstraints = CA:FALSE
keyUsage = nonRepudiation, digitalSignature, keyEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1 = registry3.ocp.example.com
DNS.2 = 192.168.3.13
EOF

openssl x509 -req -in ${CER_NAME}.csr -CA ${CER_ROOT_CA}.crt \
   -CAkey ${CER_ROOT_CA}.key -CAcreateserial -out ${CER_NAME}.crt \
   -days 3650 -extensions v3_req -extfile registry3.cnf
```



## 基于新的证书部署镜像仓库

目前版本可以指定证书，但是貌似不能修改端口，需要使用默认的8443

```
./mirror-registry install --sslCert /opt/certs/registry3.ocp.example.com.crt --sslKey /opt/certs/registry3.ocp.example.com.key
```



# 管理

安装后，可以发现实际安装了以下4个服务

* quay-app.service
* quay-pod.service 
* quay-postgres.service 
* quay-redis.service    



# 卸载 

```
./mirror-registry uninstall
```

