

# 目标

1. 记录k3s 安装过程



# 安装



## 单控制节点安装



### 安装server node



```
curl -sfL https://rancher-mirror.rancher.cn/k3s/k3s-install.sh | INSTALL_K3S_VERSION="v1.26.15+k3s1" INSTALL_K3S_MIRROR=cn sh -s - server \
  --node-external-ip 192.168.3.73 \
  --advertise-address 192.168.3.73 \
  --tls-san 192.168.3.73
```



一般而言，需要关闭防火墙

```
```



Copy  kuebconfig 文件

kubeconfig 文件在  /etc/rancher/k3s/k3s.yaml 下

```
cp /etc/rancher/k3s/k3s.yaml ~/.kube/config
```





### 安装 Agent node

获取token 

```
cat  /var/lib/rancher/k3s/server/node-token 
```



```
```







## HA 部署







# day2



## 安装helm



```
curl -LO https://get.helm.sh/helm-v3.15.0-rc.1-linux-amd64.tar.gz
```



## 安装dashboard







# 卸载



```
# 卸载 控制节点
/usr/local/bin/k3s-uninstall.sh

# 卸载Agent节点
/usr/local/bin/k3s-agent-uninstall.sh

```

