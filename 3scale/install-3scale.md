#  安装3scale operator

通过operatorhub 安装 3scale operator 

![image-20221101214948590](./install-3scale.assets/image-20221101214948590.png)



# 部署前准备

## 映射本地 imagestream

由于3scale在安装的时候，会先创建imagestream，因此需要先执行以下脚本创建imagestream的本地映射

```
[root@bastion-infra results-1666846836]# cat 3scale-mirror.yaml
apiVersion: operator.openshift.io/v1alpha1
kind: ImageContentSourcePolicy
metadata:
  name: 3scale-mirror
spec:
  repositoryDigestMirrors:
  - mirrors:
    - quay.ocp.example.com/ocp4
    source: registry.redhat.io
```





# 创建API Management 实例





![image-20221101162912989](./install-3scale.assets/image-20221101162912989.png)

```
apiVersion: apps.3scale.net/v1alpha1
kind: APIManager
metadata:
  name: apimanager-sample
  namespace: 3scale
spec:
  system:
    fileStorage:
      persistentVolumeClaim:
        storageClassName: ocs-storagecluster-cephfs
  wildcardDomain: apps.infra-cluster.example.com
  resourceRequirementsEnabled: false

```



# 登陆 3scale 

获取token

```

oc get secret system-seed -n 3scale \
  -o json | jq -r .data.ADMIN_PASSWORD | base64 -d; echo
```





# 高可用部署



## 组件说明

| POD名              | 说明                                                         | 建议副本数  |
| ------------------ | ------------------------------------------------------------ | ----------- |
| apicast-production | 生产环境的API网关                                            | 2           |
| apicast-staging    | 测试环境API网关                                              | 2           |
| system-app         | 管理人员和开发人员门户                                       | 2           |
| system-sidekiq     | 异步执行后台任务                                             | 2           |
| system-sphinx      | 文本搜索索引服务                                             | 1           |
| system-memcache    |                                                              | 1           |
| system-mysql       |                                                              | 在ocp外部署 |
| system-redis       |                                                              | 在ocp外部署 |
| backend-listener   | 负责身份验证和报告功能                                       | 2           |
| backend-worker     | 异步执行后端组件的后台任务                                   | 2           |
| backend-cron       | 为后端组件重新安排失败的任务                                 | 2           |
| backend-redis      | 存储身份验证和报告功能数据以及后端组件任务                   | 在OCP外部署 |
| zync               | 接收 OpenID Connect 相关通知，并将数据同步委托给 zync-que    | 2           |
| zync-que           | 负责创建和管理 OpenShift 路由，并与 Red Hat Single Sign-On 同步数据 | 2           |
| zync-database      | 存储 zync 组件任务的数据库                                   | 1           |



## 部署DEMO

```
apiVersion: apps.3scale.net/v1alpha1
kind: APIManager
metadata:
  name: apimanager-sample
spec:
  system:
    fileStorage:
      persistentVolumeClaim:
        storageClassName: ocs-storagecluster-cephfs
    appSpec:
      replicas: 2
    sidekiqSpec:
      replicas: 2
  zync:
    appSpec:
      replicas: 2
    queSpec:
      replicas: 2
  backend:
    cronSpec:
      replicas: 2
    listenerSpec:
      replicas: 2
    workerSpec:
      replicas: 2
  apicast:
    productionSpec:
      replicas: 2
    stagingSpec:
      replicas: 2
  wildcardDomain: apps.infra-cluster.example.com
```







# Reference

https://github.com/3scale/3scale-operator/blob/master/doc/operator-user-guide.md

