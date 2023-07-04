

# 目标

1. 为CoreOS节点设置密码





目前大概有两种方式为CoreOS节点设置密码，一种是通过MachineConfig为所有节点设置，另外一种通过grub为某一个节点设置





# 通过MachineConfig设置密码



为 core 用户创建密码，在配置中，将下面的 MYPASSWORD 替换为实际的密码

```
MYBASE64STRING=$(echo core:$(printf "MYPASSWORD" | openssl passwd -6 --stdin) | base64 -w0)
```



通过machineconfig做以下两件事情

1. 创建 /etc/core.passwd 文件，并将上面生成的登陆信息放入其中
2. 创建一个 `set-core-passwd.service` 服务，该服务在启动的时候把用户加入

```
cat << EOF > 99-set-core-passwd.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 99-worker-set-core-passwd
spec:
  config:
    ignition:
      version: 3.2.0
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,$MYBASE64STRING
        mode: 420
        overwrite: true
        path: /etc/core.passwd
    systemd:
      units:
      - name: set-core-passwd.service
        enabled: true
        contents: |
          [Unit]
          Description=Set 'core' user password for out-of-band login
          [Service]
          Type=oneshot
          ExecStart=/bin/sh -c 'chpasswd -e < /etc/core.passwd'
          [Install]
          WantedBy=multi-user.target
EOF

$ oc create -f 99-set-core-passwd.yaml
```



## 说明

只能为core用户设置密码，无法为其他用户设置密码，因为在coreos节点中，只有以下三个用户

```
[root@worker3-test7 ~]# cat /etc/passwd
root:x:0:0:root:/root:/bin/bash
core:x:1000:1000:CoreOS Admin:/var/home/core:/bin/bash
containers:x:993:995:User for housing the sub ID range for containers:/var/home/containers:/sbin/nologin
```

