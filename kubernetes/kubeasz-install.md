# 目标



1. 记录kubeasz 安装过程



# 环境准备



| NO   | name                            | IP            | CPU  | Memory |
| ---- | ------------------------------- | ------------- | ---- | ------ |
| 1    | master1-kubeasz.k8s.example.com | 192.168.3.205 | 8    | 16G    |
| 2    | master2-kubeasz.k8s.example.com | 192.168.3.206 | 8    | 16G    |
| 3    | master3-kubeasz.k8s.example.com | 192.168.3.207 | 8    | 16G    |
| 4    | worker1-kubeasz.k8s.example.com | 192.168.3.208 | 8    | 16G    |
| 5    | worker2-kubeasz.k8s.example.com | 192.168.3.209 | 8    | 16G    |
| 6    | worker3-kubeasz.k8s.example.com | 192.168.3.210 | 8    | 16G    |
| 7    | lb1-kubeasz.k8s.example.com     | 192.168.3.211 | 2    | 4G     |
| 8    | lb2-kubeasz.k8s.example.com     | 192.168.3.212 | 2    | 4G     |
| 9    | harbor-kubeasz.k8s.example.com  | 192.168.3.213 | 2    | 4G     |



创建虚拟机

```
for name in \
  master1-kubeasz \
  master2-kubeasz \
  master3-kubeasz \
  worker1-kubeasz \
  worker2-kubeasz \
  worker3-kubeasz
do
  govc vm.clone -vm centos7-base  -on=false -host=192.168.3.11 -ds=hdd -folder=kubeasz ${name}.k8s.example.com
  govc vm.change -vm /Datacenter/vm/kubeasz/${name}.k8s.example.com -c=8 -m=16384
  govc vm.power -on ${name}.k8s.example.com
done

```



为每一个node配置网络

```
nmcli c modify ens192 ipv4.addresses '192.168.3.205/24' ipv4.gateway '192.168.3.1' ipv4.dns '192.168.3.99' ipv4.method manual
nmcli c up ens192
```



## 升级kernel

```
# 载入公钥
rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
# 安装ELRepo
rpm -Uvh http://www.elrepo.org/elrepo-release-7.0-3.el7.elrepo.noarch.rpm
# 载入elrepo-kernel元数据
yum --disablerepo=\* --enablerepo=elrepo-kernel repolist
# 查看可用的rpm包
yum --disablerepo=\* --enablerepo=elrepo-kernel list kernel*
# 安装长期支持版本的kernel
yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-lt.x86_64
# 删除旧版本工具包
yum remove kernel-tools-libs.x86_64 kernel-tools.x86_64 -y
# 安装新版本工具包
yum --disablerepo=\* --enablerepo=elrepo-kernel install -y kernel-lt-tools.x86_64

#查看默认启动顺序
awk -F\' '$1=="menuentry " {print $2}' /etc/grub2.cfg  
CentOS Linux (4.4.183-1.el7.elrepo.x86_64) 7 (Core)  
CentOS Linux (3.10.0-327.10.1.el7.x86_64) 7 (Core)  
CentOS Linux (0-rescue-c52097a1078c403da03b8eddeac5080b) 7 (Core)
#默认启动的顺序是从0开始，新内核是从头插入（目前位置在0，而4.4.4的是在1），所以需要选择0。
grub2-set-default 0  
#重启并检查
reboot
```





# 安装



## master1 节点配置



### 安装ansible

```
yum install epel-release -y 
yum install ansible -y 
```





```
# 生成IP文件
cat << EOF > hosts
192.168.3.205
192.168.3.206
192.168.3.207
192.168.3.208
192.168.3.209
192.168.3.210
EOF

# 生成秘钥
ssh-keygen;

# copy 公钥到所有节点上
for host in $(cat hosts)
do
echo $host
sshpass -p "<Password>" ssh-copy-id -o StrictHostKeyChecking=no root@${host}
echo
done


# 检测结果
ansible -i hosts -m ping all
```

