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





# ocp 4.11 升级



从4.11.40 升级 到4.12.17



## 升级前执行



4.12 对应的是k8s 1.25， 该版本有部分 API 被废弃掉了，所以需要执行以下命令 处理 被废弃的API

```
oc -n openshift-config patch cm admin-acks --patch '{"data":{"ack-4.11-kube-1.25-api-removals-in-4.12":"true"}}' --type=merge
```



## 执行升级



为了避免升级的误操作，建议在执行升级命令之前，可以到对应的版本下查看一下该版本的sha256



https://mirror.openshift.com/pub/openshift-v4/clients/ocp/4.12.17/release.txt





```
oc adm upgrade --allow-explicit-upgrade --to-image quay.io/openshift-release-dev/ocp-release@sha256:$(oc adm release info quay.ocp.example.com/ocp4/openshift4:4.12.17-x86_64| grep 'Pull From' | cut -d':' -f3)
```

