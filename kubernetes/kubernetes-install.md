# 时间计划

* 第一天： 介绍docker，podman，oci 

  * docker， podman 
  * Dockerfile 
  * Docker-compose 
  * 课后作业
    * 使用docker-compose 部署一个 wordpress + mysql 的服务 

* 第二天：安装kubernetes 环境

  * 安装1.22 版本 k8s 
  * 安装网络插件
  * 安装dashboard
  * 介绍并练习一些常见的k8s对象 
  * 课后作业
    * 基于cri-o 安装 k8s 1.24 

* 第三天： 介绍k8s相关概念，练习相关试验 

  * 安装ingress controller 

  * 配置ingress 

  * 常见k8s对象和类型

  * 课后作业

    * 安装一个nginx之外的controller

* 第四天： 介绍helm 和 operator 

  * 介绍helm
  * 介绍 operator 
  * 通过helm 和operator 部署应用





# 第一天









# 安装kubernetes





```
```









# 安装后配置 



## 基础配置

```
source <(kubectl completion bash)
yum install -y bash-completion

```









## 安装nginx ingress



```



```







## 安装dashboard

```
curl -LO https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.0/aio/deploy/recommended.yaml

# 修改 service type 为 NodePort 

kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.6.0/aio/deploy/recommended.yaml

```



### 配置用户

```
[root@master1 day2]# cat dashboard-user.yaml
---
# create-user
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard

---
# rolebinding
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard

# 创建sa 以及 rolebinding 
[root@master1 day2]# kubectl apply -f dashboard-user.yaml
serviceaccount/admin-user created
clusterrolebinding.rbac.authorization.k8s.io/admin-user unchanged
  
# 获取token, 执行以下命令获取token， 将以下token 输入 dashboard 页面，登陆dashboard 
kubectl -n kubernetes-dashboard create token admin-user
  
```



```

```







## 安装网络插件



```

```

