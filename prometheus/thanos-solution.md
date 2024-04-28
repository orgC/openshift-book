# 目标

1. 简单验证thanos方案





# 部署prometheus



## prometheus1

```

nmcli con mod ens192 ipv4.addresses 192.168.3.191/24
nmcli con mod ens192 ipv4.gateway 192.168.3.1
nmcli con mod ens192 ipv4.method manual
nmcli con mod ens192 ipv4.dns "192.168.3.99"
nmcli con up ens192


```







## prometheus2



```
nmcli con mod ens192 ipv4.addresses 192.168.3.192/24
nmcli con mod ens192 ipv4.gateway 192.168.3.1
nmcli con mod ens192 ipv4.method manual
nmcli con mod ens192 ipv4.dns "192.168.3.99"
nmcli con up ens192

```







# 部署对象存储





```


setenforce 0
systemctl disable --now firewalld

```





# 部署thanos





