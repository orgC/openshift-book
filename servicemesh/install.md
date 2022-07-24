# 安装





# 配置 



## 部署bookinfo应用

```
# 部署bookinfo应用
oc apply -n bookinfo -f https://raw.githubusercontent.com/Maistra/istio/maistra-2.1/samples/bookinfo/platform/kube/bookinfo.yaml

# 创建网关
oc apply -n bookinfo -f https://raw.githubusercontent.com/Maistra/istio/maistra-2.1/samples/bookinfo/networking/bookinfo-gateway.yaml


```





## 设置 GATEWAY_URL 的值

```

```





## 添加默认目的地规则

* 没有使用m

```
oc apply -n bookinfo -f https://raw.githubusercontent.com/Maistra/istio/maistra-2.1/samples/bookinfo/networking/destination-rule-all.yaml
```

