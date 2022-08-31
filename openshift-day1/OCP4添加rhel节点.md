# 目标

* 安装OCP4 集群
* 使用RHEL8 作为worker 节点



# 安装前准备

## 同步rhel8 yum源

参考 [建立本地yum源](./rhel-yum.md) 构建yum 源



```

for repo in \
rhel-8-for-x86_64-baseos-rpms \
rhel-8-for-x86_64-appstream-rpms \
rhocp-4.10-for-rhel-8-x86_64-rpms \
fast-datapath-for-rhel-8-x86_64-rpms
do
  reposync -p /data/repos/rhel8.6 --download-metadata --repo=${repo} -n --delete
done

```



