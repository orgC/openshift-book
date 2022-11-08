

# 登陆console，配置

```
oc -n rhsso get secret \
  credential-keycloak --template={{.data.ADMIN_PASSWORD}} \
  | base64 -d ; echo

# 使用 admin/mJSED7GlKeOaHQ== 登陆 sso console
```



