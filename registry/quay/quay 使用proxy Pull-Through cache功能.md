# 目标

在日常使用镜像仓库的过程中，如果镜像仓库有proxy cache 能力，那么有些常用的镜像，我们只有第一次需要通过Internet拉下来，后面就只需要在本地镜像仓库中拉镜像就可以了。  在Quay 3.7 版本中，Proxy Pull-Through Caching 是一个TP功能，默认没有打开。本文主要两个目标

* 打开Quay Proxy Pull-Through Caching 功能
* 如何使用 Proxy



Proxy Pull-Through Caching



# 安装Quay

关于如何安装Quay ，可以参考 [安装Quay](./poc安装quay.md)

## 安装配置

修改  $QUAY/config/config.yaml 文件， 添加  `FEATURE_PROXY_CACHE: true` 

 

# 使用

## 创建cache organization

1. 创建一个Organization
2. 指定Remote Registry， 配置Remote username 和 password ，然后保存

![image-20220815085819909](./quay 使用proxy Pull-Through cache功能.assets/image-20220815085819909.png)



## 拉取镜像

通过proxy pull-through cache 拉取镜像，流程如下图所示，第一次拉取的时候，没有缓存，执行之后会自动创建对应的目录

```
podman pull registry6.ocp.example.com/cache/mysql
```



![image-20220815090823490](./quay 使用proxy Pull-Through cache功能.assets/image-20220815090823490.png)



![img](./quay 使用proxy Pull-Through cache功能.assets/quay-cache.png)





## 配置从本地cache获取镜像

```

mkdir -p $HOME/.config/containers
touch $HOME/.config/containers/registries.conf

# 在$HOME/.config/containers/registries.conf 中增加以下内容

[[registry]]
prefix = "docker.io/library"
insecure = false
blocked = false
location = "registry6.ocp.example.com/cache"
```

此时即可通过 `podman pull docker.io/library/mysql` 从本地拉取镜像





# Reference

https://cloud.redhat.com/blog/red-hat-quay-3.7-introduces-caching-storage-quotas-more

https://www.youtube.com/watch?v=oVlRDuCD6ic



