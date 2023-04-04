# RHEL8 yum源配置



## 离线同步镜像

```

subscription-manager register --username=''
subscription-manager refresh

subscription-manager list --available --matches '*OpenShift*'

subscription-manager attach --pool=<pool_id>
subscription-manager repos --disable="*"
yum repolist 



subscription-manager repos \
    --enable="rhel-8-for-x86_64-baseos-rpms" \
    --enable="rhel-8-for-x86_64-appstream-rpms" \
    --enable="rhocp-4.10-for-rhel-8-x86_64-rpms" \
    --enable="fast-datapath-for-rhel-8-x86_64-rpms"

# 第一次同步时间较长，可以通过tmux 将 session放到后台执行 
yum -y install yum-utils tmux

mkdir -p /data/repos/rhel8.6

for repo in \
rhel-8-for-x86_64-baseos-rpms \
rhel-8-for-x86_64-appstream-rpms \
rhocp-4.10-for-rhel-8-x86_64-rpms \
fast-datapath-for-rhel-8-x86_64-rpms
do
  reposync -p /data/repos/rhel8.6 --download-metadata --repo=${repo} -n --delete
done



```



## 安装 httpd server



```
yum -y install httpd

cat << EOF > /etc/httpd/conf.d/yum.conf
Alias /repos "/data/repos/rhel8"
<Directory "/data/repos/rhel8">
  Options +Indexes +FollowSymLinks
  Require all granted
</Directory>
<Location /repos>
  SetHandler None
</Location>
EOF

systemctl enable httpd;
systemctl restart httpd;
firewall-cmd --permanent --zone=public --add-service=http
firewall-cmd --reload
```



## 配置repo 文件

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









## 指定repo版本

```
# 设定repo版本，设定版本为8.6
subscription-manager release --set=8.6

# 查看当前设置的release 
subscription-manager release --show

# 查看当前有哪些release可以使用
subscription-manager release --list
```

