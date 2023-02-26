# 目标

1. 安装kubrenetes 1.26
2. 使用containerd





# 安装

安装依赖内容



## 禁用ipv6







## 安装，配置containerd

```
yum install -y containerd
```



```
mkdir -p /etc/containerd
containerd config default > /etc/containerd/config.toml

```

根据文档Container runtimes 中的内容，对于使用systemd作为init system的Linux的发行版，使用systemd作为容器的cgroup driver可以确保服务器节点在资源紧张的情况更加稳定，因此这里配置各个节点上containerd的cgroup driver为systemd

修改前面生成的配置文件 `/etc/containerd/config.toml`

```
[plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc]
  ...
  [plugins."io.containerd.grpc.v1.cri".containerd.runtimes.runc.options]
    SystemdCgroup = true
```

再修改`/etc/containerd/config.toml`中的

```
[plugins."io.containerd.grpc.v1.cri"]
  ...
  # sandbox_image = "k8s.gcr.io/pause:3.6"
  sandbox_image = "registry.aliyuncs.com/google_containers/pause:3.9"
```



配置 containerd 开机启动

```
systemctl enable containerd --now
```



## 安装master节点



```
kubeadm init --kubernetes-version=v1.26.1 --pod-network-cidr=10.244.0.0/16 --image-repository=registry.aliyuncs.com/google_containers

```



## 安装node 节点

执行 kubeadm join 

```


```





# troubleshooting



