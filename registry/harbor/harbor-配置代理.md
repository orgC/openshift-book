

# 目标

1. harbor 配置为代理模式，通过 本地harbor 为桥梁，pull 下来 docker.io 上的镜像 



# harbor 配置



参考[harbor local registry mirror](https://github.com/goharbor/harbor/blob/main/contrib/Configure_mirror.md) 说明进行配置



## harbor 要求



按照文档说明，如果需要把harbor 配置为 代理模式，需要在安装的时候设置，并且不能push 镜像到harbor。因此建议单独部署一个纯粹用作 pull image 的harbor。



```
vim common/config/registry/config.yml 

...
proxy:
  remoteurl: https://registry-1.docker.io
  
```



执行  `./prepare`



## 配置代理 



打开  harbor.yml， 添加proxy 配置，这个配置是为了让harbor  通过代理连接到 后端

```
proxy:
  http_proxy: 192.168.3.90:7890
  https_proxy: 192.168.3.90:7890
  no_proxy:
  components:
    - core
    - jobservice
    - trivy
```







## 配置 proxy 模式的library 

创建一个 registry endpoint

![image-20240717202044521](./harbor-%E9%85%8D%E7%BD%AE%E4%BB%A3%E7%90%86.assets/image-20240717202044521.png)



将默认的 library 库删掉，创建一个新的 library，模式选择为 proxy，选择endpoint 为刚才创建的docker-hub 



![image-20240717202219620](./harbor-%E9%85%8D%E7%BD%AE%E4%BB%A3%E7%90%86.assets/image-20240717202219620.png)



![image-20240717202145010](./harbor-%E9%85%8D%E7%BD%AE%E4%BB%A3%E7%90%86.assets/image-20240717202145010.png)





# docker-ce 配置

修改  /etc/docker/daemon.json 文件，添加 registry-mirrors 

```
# cat /etc/docker/daemon.json
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "registry-mirrors": [
    "https://harbor.k8s.example.com"
  ],
  ... 
```





`docker info` 结果查看 



![image-20240717202847800](./harbor-%E9%85%8D%E7%BD%AE%E4%BB%A3%E7%90%86.assets/image-20240717202847800.png)



# 验证结果







# Reference



