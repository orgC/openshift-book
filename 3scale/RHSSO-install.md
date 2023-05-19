[TOC]





# install



安装 rhsso operator 

![image-20230519155623730](./RHSSO-install.assets/image-20230519155623730.png)



创建 instance 

![image-20230519160455140](./RHSSO-install.assets/image-20230519160455140.png)

直接使用默认值，创建实例

![image-20230519160739042](./RHSSO-install.assets/image-20230519160739042.png)





# 登陆console，配置

```
oc -n rhsso get secret \
  credential-example-keycloak --template={{.data.ADMIN_PASSWORD}} \
  | base64 -d ; echo

# 使用 admin/mJSED7GlKeOaHQ== 登陆 sso console
```



