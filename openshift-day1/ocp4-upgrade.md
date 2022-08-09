# 目标



* 小版本升级， 从4.10.4 升级到 4.10.24
* 大版本升级，从4.10 升级到 4.11



# 小版本升级

## 准备工作

同步新版本的OCP image，并同步到本地镜像仓库 [离线operatorhub](./离线operatorhub.md)



## 获取 image 信息



```
# 从文件中获取对应的
https://mirror.openshift.com/pub/openshift-v4/x86_64/clients/ocp/4.10.24/release.txt

quay.io/openshift-release-dev/ocp-release@sha256:aab51636460b5a9757b736a29bc92ada6e6e6282e46b06e6fd483063d590d62a


oc adm upgrade --allow-explicit-upgrade=false --to-image='quay.io/openshift-release-dev/ocp-release@sha256:aab51636460b5a9757b736a29bc92ada6e6e6282e46b06e6fd483063d590d62a'
```

