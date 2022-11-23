

![image-20221102153629353](./API with SSO.assets/image-20221102153629353.png)



# 准备工作

## 部署应用

```

oc new-project secure-oauth


```

### book-api.yml

```
[root@bastion-infra manifests]# cat book-api.yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: books-api-v2
spec:
  selector:
    matchLabels:
      app: books-api
      version: v2
  replicas: 1
  template:
    metadata:
      labels:
        app: books-api
        version: v2
    spec:
      containers:
        - name: books-api
          image: quay.io/redhattraining/3scale-books-api:2
          ports:
            - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: books-api
spec:
  selector:
    app: books-api
    version: v2
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
```



### book-frontend.yml

```
[root@bastion-infra manifests]# cat book-frontend.yml
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: books-frontend-v2
spec:
  selector:
    matchLabels:
      app: books-frontend
      version: v2
  replicas: 1
  template:
    metadata:
      labels:
        app: books-frontend
        version: v2
    spec:
      containers:
        - name: books-frontend
          image: quay.io/redhattraining/3scale-books-frontend:v2
          ports:
            - containerPort: 3000
          envFrom:
            - configMapRef:
                name: book-config
---
apiVersion: v1
kind: Service
metadata:
  name: books-frontend
spec:
  selector:
    app: books-frontend
    version: v2
  ports:
    - protocol: TCP
      port: 3000
      targetPort: 3000
---
apiVersion: route.openshift.io/v1
kind: Route
metadata:
  name: books-frontend
spec:
  port:
    targetPort: 3000
  to:
    name: books-frontend
---
apiVersion: v1
data:
  REACT_APP_CLIENT_ID: change-me
  REACT_APP_BASE_URL: secure-oauth-3scale-apicast-staging.apps.infra-cluster.example.com
  REACT_APP_KEYCLOAK_URL: https://keycloak-rhsso.apps.infra-cluster.example.com/auth
  REACT_APP_ENDPOINT: /books
  REACT_APP_KEYCLOAK_REALM: demo
kind: ConfigMap
metadata:
  name: book-config
```







## 创建product

创建名为 secure_oauth 的product 

![image-20221102223309854](./API with SSO.assets/image-20221102223309854.png)



## 创建 application-plan

在 secure_oauth  product 下，创建 secure_oauth_basic application plan

![image-20221102223443756](./API with SSO.assets/image-20221102223443756.png)



## 创建 application 

创建 secure_oauth_app  application 





## 创建Backend

| name         | System name  | Private base URL                                             |
| ------------ | ------------ | ------------------------------------------------------------ |
| books_api_v2 | books_api_v2 | http://books-api.secure-oauth.svc.cluster.local:80/api/v2/books |



![image-20221102224204402](./API with SSO.assets/image-20221102224204402.png)





## 为product 添加 backend



![image-20221102224530871](./API with SSO.assets/image-20221102224530871.png)



## keycloak 安装配置

### 安装RHSSO  operator

通过operatorhub 安装operator ，创建rhsso namespace。以下示例中，sso operator 安装在rhsso 中



### 创建keycloak 实例 

```
oc project rhsso 

# 创建 keycloak 实例
cat << EOF | oc apply -f -
kind: Keycloak
apiVersion: keycloak.org/v1alpha1
metadata:
  name: keycloak
  labels:
    app: sso
spec:
  instances: 1
  externalAccess:
    enabled: true
EOF

# 这里要稍等等待几分钟 

# 创建realm 
cat << EOF | oc apply -f -
kind: KeycloakRealm
apiVersion: keycloak.org/v1alpha1
metadata:
  name: demo-keycloakrealm
  labels:
    realm: demo
spec:
  realm:
    id: demo
    realm: demo
    enabled: true
    displayName: demo
  instanceSelector:
    matchLabels:
      app: sso
EOF


# 创建用户

cat << EOF | oc apply -f -
kind: KeycloakUser
apiVersion: keycloak.org/v1alpha1
metadata:
  name: zhangsan-user
  labels:
    app: sso
spec:
  user:
    username: zhangsan
    firstName: zhang
    lastName: zhangsan
    email: zhangsan@example.com
    enabled: true
    emailVerified: true
    realmRoles:
      - offline_access
      - uma_authorization
      - default-roles-demo
    credentials:
    - type: password
      value: redhat
  realmSelector:
    matchLabels:
      realm: demo
EOF

```



### 登陆SSO

执行以下命令获取sso  console 密码 

```
oc -n rhsso get secret \
  credential-keycloak --template={{.data.ADMIN_PASSWORD}} \
  | base64 -d ; echo
```



# DEMO



## 同步CA



执行以下脚本

1. 获取sso 证书
2. 将其加入到3scale CA 中

```

#!/bin/env bash

OCP_USER="admin"
OCP_PASS="admin"
OCP_URL="https://api.infra-cluster.example.com:6443"

RHSSO_URL="keycloak-rhsso.apps.infra-cluster.example.com"
RHSSO_PORT="443"
#vars cannot start with a number
T_SCALE_PROJECT=3scale

ocp_login() {
    oc login -u "${OCP_USER}" -p "${OCP_PASS}" "${OCP_URL}"
}

save_rhsso_cert() {
    echo -n | openssl s_client -connect "${RHSSO_URL}":"${RHSSO_PORT}" -servername "${RHSSO_URL}" --showcerts | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > customCA.pem
}

inject_rhsso_cert_to_zync() {
    zync_pod=$(oc -n "${T_SCALE_PROJECT}" get pods -l threescale_component_element=zync-que -o name)
    oc -n "${T_SCALE_PROJECT}" exec "${zync_pod}" --  cat /etc/pki/tls/cert.pem > zync.pem
    # Add RHSSO cert to zync's cert chain
    cat customCA.pem >> zync.pem
    oc -n "${T_SCALE_PROJECT}" create configmap zync-new-ca-bundle --from-file=./zync.pem
    oc -n "${T_SCALE_PROJECT}" set volume dc/zync-que --add --name=zync-new-ca-bundle \
      --mount-path /etc/pki/tls/zync/zync.pem \
      --sub-path zync.pem \
      --source='{"configMap":{"name":"zync-new-ca-bundle","items":[{"key":"zync.pem","path":"zync.pem"}]}}' \
    && oc -n "${T_SCALE_PROJECT}" set env dc/zync-que SSL_CERT_FILE=/etc/pki/tls/zync/zync.pem
}

main() {
    ocp_login
    save_rhsso_cert
    inject_rhsso_cert_to_zync
}

main
```





## 添加 client

登陆 sso console

https://keycloak-rhsso.apps.infra-cluster.example.com/auth/admin/master/console/#/realms/demo

选择 client->create->import ,  将以下文件内容导入

```
{
    "clientId": "zync-client",
    "surrogateAuthRequired": false,
    "enabled": true,
    "alwaysDisplayInConsole": false,
    "clientAuthenticatorType": "client-secret",
    "redirectUris": [],
    "webOrigins": [],
    "notBefore": 0,
    "bearerOnly": false,
    "consentRequired": false,
    "standardFlowEnabled": false,
    "implicitFlowEnabled": false,
    "directAccessGrantsEnabled": false,
    "serviceAccountsEnabled": true,
    "publicClient": false,
    "frontchannelLogout": false,
    "protocol": "openid-connect",
    "attributes": {
        "saml.assertion.signature": "false",
        "id.token.as.detached.signature": "false",
        "saml.multivalued.roles": "false",
        "saml.force.post.binding": "false",
        "saml.encrypt": "false",
        "oauth2.device.authorization.grant.enabled": "false",
        "backchannel.logout.revoke.offline.tokens": "false",
        "saml.server.signature": "false",
        "saml.server.signature.keyinfo.ext": "false",
        "use.refresh.tokens": "true",
        "exclude.session.state.from.auth.response": "false",
        "oidc.ciba.grant.enabled": "false",
        "saml.artifact.binding": "false",
        "backchannel.logout.session.required": "true",
        "client_credentials.use_refresh_token": "false",
        "saml_force_name_id_format": "false",
        "saml.client.signature": "false",
        "tls.client.certificate.bound.access.tokens": "false",
        "require.pushed.authorization.requests": "false",
        "saml.authnstatement": "false",
        "display.on.consent.screen": "false",
        "saml.allow.ecp.flow": "false",
        "saml.onetimeuse.condition": "false"
    },
    "authenticationFlowBindingOverrides": {},
    "fullScopeAllowed": true,
    "nodeReRegistrationTimeout": -1,
    "protocolMappers": [
        {
            "name": "Client ID",
            "protocol": "openid-connect",
            "protocolMapper": "oidc-usersessionmodel-note-mapper",
            "consentRequired": false,
            "config": {
                "user.session.note": "clientId",
                "id.token.claim": "true",
                "access.token.claim": "true",
                "claim.name": "clientId",
                "jsonType.label": "String"
            }
        },
        {
            "name": "Client IP Address",
            "protocol": "openid-connect",
            "protocolMapper": "oidc-usersessionmodel-note-mapper",
            "consentRequired": false,
            "config": {
                "user.session.note": "clientAddress",
                "id.token.claim": "true",
                "access.token.claim": "true",
                "claim.name": "clientAddress",
                "jsonType.label": "String"
            }
        },
        {
            "name": "Client Host",
            "protocol": "openid-connect",
            "protocolMapper": "oidc-usersessionmodel-note-mapper",
            "consentRequired": false,
            "config": {
                "user.session.note": "clientHost",
                "id.token.claim": "true",
                "access.token.claim": "true",
                "claim.name": "clientHost",
                "jsonType.label": "String"
            }
        }
    ],
    "defaultClientScopes": [
        "web-origins",
        "profile",
        "roles",
        "email"
    ],
    "optionalClientScopes": [
        "address",
        "phone",
        "offline_access",
        "microprofile-jwt"
    ],
    "access": {
        "view": true,
        "configure": true,
        "manage": true
    }
}
```



保存client 

![image-20221107141848057](./API with SSO.assets/image-20221107141848057.png)



进入 zync-client，选择service account roles， 如下图所示，选择realm-management->manange-client,  将其加入 Assigned Roles 中。否则后面  在3scale 创建应用的时候，无法自动的在RHSSO上创建client

![image-20221115191712626](./API with SSO.assets/image-20221115191712626.png)



## 配置 product



1. 选择 product->secure_oauth->setting-> OpenID Connect Use OpenID 
2. 修改OpenID Connect Issuer:  修改的值为 https://CLIENT-ID:CLIENT-SECRET@RHSSO-URL
   1. **Client-id**: `zync-client`
   2. **Client-secret**:  从 sso  zync-client  secret 获取 
   3. **RHSSO URL**: `keycloak-rhsso.apps.infra-cluster.example.com/auth/realms/demo`

> https://<CLIENT_ID>:<CLIENT_SECRET>@<HOST>:<PORT>/auth/realms/<REALM_NAME>
>
> https://zync-client:zLsvhO1plK4g1jks5lY8lPW87BlLGEGU@keycloak-rhsso.apps.infra-cluster.example.com/auth/realms/demo

![image-20221107142459513](./API with SSO.assets/image-20221107142459513.png)



![image-20221107142224565](./API with SSO.assets/image-20221107142224565.png)







## 创建application 

创建application sso_app，同时记下 Client ID： 28864d12

![image-20221102231324816](./API with SSO.assets/image-20221102231324816.png)



## 修改 SSO 相关配置

登陆到SSO，选择 do240->clients， 可以看到新创建的client 中有一个 与上边的application 名字一致 （28864d12）

![image-20221102231423987](./API with SSO.assets/image-20221102231423987.png)





## 创建 configmap 

* REACT_APP_CLIENT_ID ： 自动生成的 

```
cat << EOF | oc apply -f -
apiVersion: v1
data:
  REACT_APP_BASE_URL: secure-oauth-3scale-apicast-staging.apps.infra-cluster.example.com
  REACT_APP_CLIENT_ID: 28864d12
  REACT_APP_ENDPOINT: /books
  REACT_APP_KEYCLOAK_REALM: demo
  REACT_APP_KEYCLOAK_URL: https://keycloak-rhsso.apps.infra-cluster.example.com/auth
kind: ConfigMap
metadata:
  name: book-config
  namespace: secure-oauth
EOF

```





```

oc -n secure-oauth delete pod \
  -l app=books-frontend
```





## 添加新的policy

1. 选择 product->secure_oauth->integration->policies->Add policy 
2. 选择 CORS Request Handling 

> 注意下图中的顺序，需要把CORS Request 放到第一位，否则会有问题

![image-20221102231754759](./API with SSO.assets/image-20221102231754759.png)







## 访问页面

此时直接访问 demo2 中route 的地址 `http://books-frontend-demo2.apps.infra-cluster.example.com/`

发现会有以下报错

![image-20221121160034903](./API with SSO.assets/image-20221121160034903.png)



解决方案：

复制红框中的地址，在另一个窗口打开。

![image-20221121160153720](./API with SSO.assets/image-20221121160153720.png)

切回原来的界面，然后刷新窗口即可

![image-20221121160239816](./API with SSO.assets/image-20221121160239816.png)



至此，demo 完成
