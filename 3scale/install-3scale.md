#  安装3scale operator

通过operatorhub 安装 3scale operator 

![image-20221101214948590](./install-3scale.assets/image-20221101214948590.png)







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





