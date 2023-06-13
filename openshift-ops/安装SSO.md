

[TOC]



# 目标

1. 通过 template 安装 sso
2. 通过operator 安装sso
3. 配置openshift 对接sso





# 通过template 安装sso



## 离线环境导入imagestream





## 安装sso

创建 Project 

![image-20230611165153792](./安装SSO.assets/image-20230611165153792.png)





![image-20230611165313051](./安装SSO.assets/image-20230611165313051.png)



选择 SSO 7.5 



![image-20230611170717977](./安装SSO.assets/image-20230611170717977.png)



手工设置 SSO 账号，密码，这里如果没有设置的话，后面会自动生成。





部署完成后

![image-20230611172105547](./安装SSO.assets/image-20230611172105547.png)





![image-20230611182654306](./安装SSO.assets/image-20230611182654306.png)

选择 openid

![image-20230611182735246](./安装SSO.assets/image-20230611182735246.png)





配置 



![image-20230611182614370](./安装SSO.assets/image-20230611182614370.png)



在这里找到route-ca 证书

![image-20230611182904297](./安装SSO.assets/image-20230611182904297.png)

copy证书



![image-20230611182946770](./安装SSO.assets/image-20230611182946770.png)

回到之前user 配置页面，把证书贴上去

![image-20230611183046704](./安装SSO.assets/image-20230611183046704.png)





此时 auth operator 会重启，等相关pod重启后，更新完成



![image-20230611183204383](./安装SSO.assets/image-20230611183204383.png)





退出当前登录用户

![image-20230611183404461](./安装SSO.assets/image-20230611183404461.png)



## 配置ocp 与sso 对接



