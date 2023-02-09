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





#  最小化部署

默认部署方案，最小化部署



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



组件默认配置



| system-sidekiq     | 100m  | 1000m    | 500Mi  | 2Gi   |
| ------------------ | ----- | -------- | ------ | ----- |
| system-sphinx      | 80m   | 1000m    | 250Mi  | 512Mi |
| system-redis       | 150m  | 500m     | 256Mi  | 32Gi  |
| system-mysql       | 250m  | No limit | 512Mi  | 2Gi   |
| system-postgresql  | 250m  | No limit | 512Mi  | 2Gi   |
| backend-listener   | 500m  | 1000m    | 550Mi  | 700Mi |
| backend-worker     | 150m  | 1000m    | 50Mi   | 300Mi |
| backend-cron       | 50m   | 150m     | 40Mi   | 80Mi  |
| backend-redis      | 1000m | 2000m    | 1024Mi | 32Gi  |
| apicast-production | 500m  | 1000m    | 64Mi   | 128Mi |
| apicast-staging    | 50m   | 100m     | 64Mi   | 128Mi |
| zync               | 150m  | 1        | 250M   | 512Mi |
| zync-que           | 250m  | 1        | 250M   | 512Mi |
| zync-database      | 50m   | 250m     | 250M   | 2G    |



## 创建 redis secret

### redis sentinel 集群



[Redis sentinel 集群部署](https://juejin.cn/post/7090907323522088991)



集群信息

| node | ip            |
| ---- | ------------- |
|      | 192.168.3.131 |
|      | 192.168.3.132 |
|      | 192.168.3.133 |



### 参数说明



| 参数             | 说明                                                         |
| ---------------- | ------------------------------------------------------------ |
| REDIS_QUEUES_URL | redis://[:redis-password@]redis-group[/db]，其中[:redis-password@]是可选项，如果redis没有配置密码，则可以写成 redis://redis-group[/db] |
|                  |                                                              |

### 创建 backend-redis secret

backend-redis 配置

```
kind: Secret
apiVersion: v1
metadata:
  name: backend-redis
  namespace: 3scale
  labels:
    app: 3scale-api-management
    threescale_component: backend
data:
  REDIS_QUEUES_SENTINEL_HOSTS: '192.168.3.131:26379,192.168.3.132:26379,192.168.3.133:26379'
  REDIS_QUEUES_SENTINEL_ROLE: 'master'
  REDIS_QUEUES_URL: redis://mymaster:6379/1
  REDIS_STORAGE_SENTINEL_HOSTS: '192.168.3.131:26379,192.168.3.132:26379,192.168.3.133:26379'
  REDIS_STORAGE_SENTINEL_ROLE: 'master'
  REDIS_STORAGE_URL: redis://mymaster:6379/0
type: Opaque
```



通过base64 序列化，转化为以下形式

```
kind: Secret
apiVersion: v1
metadata:
  name: backend-redis
  namespace: 3scale
  labels:
    app: 3scale-api-management
    threescale_component: backend
data:
  REDIS_QUEUES_SENTINEL_HOSTS: 'MTkyLjE2OC4zLjEzMToyNjM3OSwxOTIuMTY4LjMuMTMyOjI2Mzc5LDE5Mi4xNjguMy4xMzM6MjYzNzk='
  REDIS_QUEUES_SENTINEL_ROLE: 'bWFzdGVy'
  REDIS_QUEUES_URL: cmVkaXM6Ly9teW1hc3Rlcjo2Mzc5LzE=
  REDIS_STORAGE_SENTINEL_HOSTS: 'MTkyLjE2OC4zLjEzMToyNjM3OSwxOTIuMTY4LjMuMTMyOjI2Mzc5LDE5Mi4xNjguMy4xMzM6MjYzNzk='
  REDIS_STORAGE_SENTINEL_ROLE: 'bWFzdGVy'
  REDIS_STORAGE_URL: cmVkaXM6Ly9teW1hc3Rlcjo2Mzc5LzA=
type: Opaque
```



###  创建 system-redis secret

system-redis 内容

```
kind: Secret
apiVersion: v1
metadata:
  name: system-redis
  namespace: 3scale
  labels:
    app: 3scale-api-management
    threescale_component: system
data:
  NAMESPACE: '3scalesystem'
  SENTINEL_HOSTS: '192.168.3.131:26379,192.168.3.132:26379,192.168.3.133:26379'
  SENTINEL_ROLE: 'master'
  URL: redis://mymaster:6379/2
type: Opaque
```



将参数通过base64 序列化，基于以下内容创建secret

```
kind: Secret
apiVersion: v1
metadata:
  name: system-redis
  namespace: 3scale
  labels:
    app: 3scale-api-management
    threescale_component: system
data:
  NAMESPACE: 'M3NjYWxlc3lzdGVt'
  SENTINEL_HOSTS: 'MTkyLjE2OC4zLjEzMToyNjM3OSwxOTIuMTY4LjMuMTMyOjI2Mzc5LDE5Mi4xNjguMy4xMzM6MjYzNzk='
  SENTINEL_ROLE: 'bWFzdGVy'
  URL: cmVkaXM6Ly9teW1hc3Rlcjo2Mzc5LzI=
type: Opaque
```





## 创建mysql secret

> 如果mysql 中有数据，建议先将相关数据库清理干净
>
> 注意：部署 mysql时，需要在配置文件中添加 authentication plugin，在MySQL configuration file 中添加以下内容
>
> ```
> [mysqld]
> default_authentication_plugin=mysql_native_password
> ```



### MySQL 信息

| 参数        | value         |
| ----------- | ------------- |
| IP          | 192.168.3.134 |
| user        | 3scale        |
| DB          | 3scale        |
| DB-Password | 123456        |



### 创建 system-database secret 




system-database 内容 

```
kind: Secret
apiVersion: v1
metadata:
  name: system-database
  namespace: 3scale
  labels:
    app: 3scale-api-management
    threescale_component: system
data:
  DB_PASSWORD: 123456
  DB_USER: 3scale
  URL: mysql2://3scale:123456@192.168.3.134/3scale
type: Opaque
```

将参数通过base64 序列化，基于以下内容创建secret

```
kind: Secret
apiVersion: v1
metadata:
  name: system-database
  namespace: 3scale
  labels:
    app: 3scale-api-management
    threescale_component: system
data:
  DB_PASSWORD: MTIzNDU2
  DB_USER: M3NjYWxl
  URL: bXlzcWwyOi8vM3NjYWxlOjEyMzQ1NkAxOTIuMTY4LjMuMTM0LzNzY2FsZQ==
type: Opaque
```







##  创建实例

对接外部实例的时候，注意，在对接的时候，尽量先把MySQL和Redis 都清理干净，否则可能会有问题



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
  externalComponents:
    backend:
      redis: true
    system:
      database: false
      redis: true
    zync:
      database: false
```





域名：生产环境api-cast 域名 





# 备份和恢复



## 备份

3scale 本身提供了备份能力，在operator中选择 APIManageBackup 即可实现备份

> 注意： 这个备份主要备份的是ocp中的secret和configmap等3scale的安装配置信息，没有包含3scale创建的product和application等数据，这些内容是被保存在后端的MySQL中的，

![image-20230206165221465](./install-3scale.assets/image-20230206165221465.png)

参考以下内容修改脚本

```
kind: APIManagerBackup
apiVersion: apps.3scale.net/v1alpha1
metadata:
  name: apimanagerbackup-sample
  namespace: 3scale
spec:
  backupDestination:
    persistentVolumeClaim:
      resources:
        requests: "10Gi"
```







## 恢复

> 我们在配置的时候，指定了外部redis 和 外部mysql，通过测试发现，实际数据保存在MySQL中，redis中保存的是临时数据。可以考虑不备份redis数据，如果要恢复的时候





```

kind: APIManagerRestore
apiVersion: apps.3scale.net/v1alpha1
metadata:
  name: apimanagerrestore-sample
  namespace: 3scale
spec:
  restoreSource:
    persistentVolumeClaim:
      claimSource:
        claimName: apimanagerbackup-sample   # 这里指定之前备份的PVC
```





## 说明



我们在配置的时候，指定了外部redis 和 外部mysql，通过测试发现，实际数据保存在MySQL中，redis中保存的是临时数据。可以考虑不备份redis数据，如果要恢复的时候



#  对接SSO



## 在sso创建client



![image-20230206182831701](./install-3scale.assets/image-20230206182831701.png)



## 在3scale上配置对接sso



![image-20230206182648715](./install-3scale.assets/image-20230206182648715.png)

注意，创建用户的时候，必须选择 Email Verified on， 否则会报错， **Your account isn't active or hasn't been approved yet **

[解决方案](https://access.redhat.com/solutions/3969961)



![image-20230206192721258](./install-3scale.assets/image-20230206192721258.png)







# 附录

## 安装postgresql 环境

安装postgresql

```

dnf install -y https://download.postgresql.org/pub/repos/yum/reporpms/EL-8-x86_64/pgdg-redhat-repo-latest.noarch.rpm

dnf -qy module disable postgresql

sudo dnf install -y postgresql13-server

/usr/pgsql-13/bin/postgresql-13-setup initdb
systemctl enable postgresql-13
sudo systemctl start postgresql-13
systemctl status postgresql-13

su - postgres
 
```



# 多租户

3scale 支持多租户， 配置多租户方式如下

1. 访问 master console ， 在route 中有一个master route （master.apps.infra-cluster.example.com）

Master 页面的访问地址是 https://master.apps.infra-cluster.example.com

密码： ` oc get secret system-seed -n 3scale   -o json | jq -r .data.MASTER_PASSWORD | base64 -d; echo`

登陆后，显示内容如下，这里有一个master 标记

![image-20230206194656232](./install-3scale.assets/image-20230206194656232.png)



2. 创建用户

   选择 Audience->Accounts->Listing->Create 创建

   创建Tom 用户，属于IT Org 

   ![image-20230206194955615](./install-3scale.assets/image-20230206194955615.png)

3. 激活用户

![image-20230206195134155](./install-3scale.assets/image-20230206195134155.png)







## 安装redis 环境







# Reference

https://github.com/3scale/3scale-operator/blob/master/doc/operator-user-guide.md

