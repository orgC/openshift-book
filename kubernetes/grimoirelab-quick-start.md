

# 目标

1. 学习 grimoirelab



# 部署



## 准备工作



修改 vm.max_map_count 大小



````
vi /etc/sysctl.conf 

...
vm.max_map_count = 655360
...

# 执行以下命令，生效
sysctl -p
````



