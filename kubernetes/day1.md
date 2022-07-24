# lab 环境

## 镜像仓库

```
地址： https://192.168.26.100
账号： admin/Harbor12345
```



## http server

```
http://192.168.26.100/repos/
```





# 安装docker



```
hostnamectl set-hostname docker.myk8s.example.com

cat <<EOF>> /etc/hosts
192.168.26.100 registry.myk8s.example.com
192.168.26.133 docker.myk8s.example.com
EOF

nmcli con mod ens160 ipv4.addresses 192.168.26.90/24
nmcli con mod ens160 ipv4.gateway 192.168.26.2
nmcli con mod ens160 ipv4.method manual
nmcli con mod ens160 ipv4.dns "192.168.26.2"
nmcli con up ens160


dnf config-manager --add-repo=https://download.docker.com/linux/centos/docker-ce.repo
yum install -y docker-ce 

systemctl enable --now docker 

# 修改 docker-ce cgroup driver  

cat <<EOF | sudo tee /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2"
}
EOF


systemctl daemon-reload && systemctl restart docker


## 安装docker-compose 
curl -LO https://github.com/docker/compose/releases/download/v2.6.0/docker-compose-linux-x86_64

mv docker-compose-linux-x86_64 /usr/local/bin/docker-compose
chmod a+x /usr/local/bin/docker-compose

## 本地安装 
curl -o /usr/local/bin/docker-compose http://192.168.26.100/repos/docker-compose 
chmod a+x /usr/local/bin/docker-compose




```





# docker demo



准备镜像

```
podman pull registry.redhat.io/rhel8/mysql-80:1
podman tag registry.redhat.io/rhel8/mysql-80:1 quay.io/junkai/training:mysql-80
podman push --remove-signatures  quay.io/junkai/training:mysql-80
```



## 目标

* docker run命令可从容器镜像创建和启动容器
* 容器通过使用 -d 标志在后台执行，或者通过使用 -it 标志交互执行
* 有些容器镜像要求提供环境变量，这些变量可通过-e命令传递





## lab1: 获取镜像

```


```





## lab1: 运行一个mysql容器，在内部执行mysql命令



```
docker run --name mysql-basic \
 -e MYSQL_USER=user1 -e MYSQL_PASSWORD=mypa55 \
 -e MYSQL_DATABASE=items -e MYSQL_ROOT_PASSWORD=r00tpa55 \
 -d quay.io/junkai/training:mysql-80
 
[root@docker ~]# docker ps
CONTAINER ID   IMAGE                              COMMAND                  CREATED         STATUS         PORTS      NAMES
a4b8aa0105fb   quay.io/junkai/training:mysql-80   "container-entrypoin…"   3 minutes ago   Up 3 minutes   3306/tcp   mysql-basic
[root@docker ~]#
[root@docker ~]# docker exec -it a4 bash
bash-4.4$
bash-4.4$ mysql -uroot
Welcome to the MySQL monitor.  Commands end with ; or \g.
Your MySQL connection id is 9
Server version: 8.0.26 Source distribution

Copyright (c) 2000, 2021, Oracle and/or its affiliates.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

mysql>

### exec ##### 

show databases;
use items;

CREATE TABLE Projects (id int NOT NULL,
 name varchar(255) DEFAULT NULL,
 code varchar(255) DEFAULT NULL,
 PRIMARY KEY (id));
 
insert into Projects (id, name, code) values (1,'DevOps','demo');

select * from Projects;

```



## lab2：通过docker 提供本地服务

```

docker run -d -p 8080:80 --name httpd-basic quay.io/redhattraining/httpd-parent:2.4

curl http://localhost:8080

# 修改显示内容

docker exec -it httpd-basic /bin/bash
echo "Hello World" > /var/www/html/index.html

curl http://localhost:8080

# commit 生成新的镜像, 推送到远端镜像仓库 
docker commit -m "change http message" 4002baa7593e registry.myk8s.example.com/demo/myhttpd:v1
docker images
docker push registry.myk8s.example.com/demo/myhttpd:v1

```



