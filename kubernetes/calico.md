

# 目标

1. 研究calico 原理





# calico 架构



![calico-architecture](./calico.assets/calico-architecture.png)



## felix

Felix会监听ECTD中心的存储，从它获取事件，比如说用户在这台机器上加了一个IP，或者是创建了一个容器等。用户创建pod后，Felix负责将其网卡、IP、MAC都设置好，然后在内核的路由表里面写一条，注明这个IP应该到这张网卡。同样如果用户制定了隔离策略，Felix同样会将该策略创建到ACL中，以实现隔离



## etcd

分布式键值存储，主要负责网络元数据一致性，确保Calico网络状态的准确性，可以与kubernetes共用



## BIRD

BIRD是一个标准的路由程序，它会从内核里面获取哪一些IP的路由发生了变化，然后通过标准BGP的路由协议扩散到整个其他的宿主机上，让外界都知道这个IP在这里，你们路由的时候得到这里来



# install



## The Calico datastore

Calico 有两种数据存储驱动

* etcd: 直接链接到一个etcd集群
* Kubernetes： 通过kubernetes 进行数据保存

### 使用kubernetes 的好处

1. 不需要一个单独的etcd集群，方便管理
2. 可以通过Kubernetes的RBAC进行ETCD资源的访问控制
3. 可以通过kubernetes 的audit log 来记录etcd的操作记录

### 使用外部etcd的好处

1. 可以在非kubernetes环境中部署
2. 允许分离 Kubernetes 和 Calico 资源，例如允许独立etcd扩展数据存储
3. 允许运行包含多个 Kubernetes 集群的 Calico 集群，例如，具有 Calico 主机保护的裸机服务器与 Kubernetes 集群互通；或多个 Kubernetes 集群之间互通







# calicoctl





# Calico 网络



Calico 网络支持两种， IPIP 和 BGP



## IPIP

从字面来理解，就是把一个IP数据包又套在一个IP包里，即把 IP 层封装到 IP 层的一个 tunnel。它的作用其实基本上就相当于一个基于IP层的网桥！一般来说，普通的网桥是基于mac层的，根本不需 IP，而这个 ipip 则是通过两端的路由做一个 tunnel，把两个本来不通的网络通过点对点连接起来。 

 

## BGP

边界网关协议（Border Gateway Protocol, BGP）是互联网上一个核心的去中心化自治路由协议。它通过维护IP路由表或‘前缀’表来实现自治系统（AS）之间的可达性，属于矢量路由协议。BGP不使用传统的内部网关协议（IGP）的指标，而使用基于路径、网络策略或规则集来决定路由。因此，它更适合被称为矢量性协议，而不是路由协议。BGP，通俗的讲就是讲接入到机房的多条线路（如电信、联通、移动等）融合为一体，实现多线单IP，BGP 机房的优点：服务器只需要设置一个IP地址，最佳访问路由是由网络上的骨干路由器根据路由跳数与其它技术指标来确定的，不会占用服务器的任何系统。





# demo

```
# 
kubectl create deployment client --image  quay.io/junkai/tools

kubectl create deployment server --image  quay.io/junkai/tools
```



