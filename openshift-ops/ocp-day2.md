

# Rhcos节点设置时区



## master node



```
cat << EOF | oc create -f -
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: master-custom-timezone-configuration
spec:
  config:
    ignition:
      config: {}
      security:
        tls: {}
      timeouts: {}
      version: 2.2.0
    networkd: {}
    passwd: {}
    storage: {}
    systemd:
      units:
      - contents: |
          [Unit]
          Description=set timezone
          After=network-online.target

          [Service]
          Type=oneshot
          ExecStart=timedatectl set-timezone Asia/Shanghai

          [Install]
          WantedBy=multi-user.target
        enabled: true
        name: custom-timezone.service
  osImageURL: ""
EOF
```





## worker node 



```
cat << EOF | oc create -f -
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: worker-custom-timezone-configuration
spec:
  config:
    ignition:
      config: {}
      security:
        tls: {}
      timeouts: {}
      version: 2.2.0
    networkd: {}
    passwd: {}
    storage: {}
    systemd:
      units:
      - contents: |
          [Unit]
          Description=set timezone
          After=network-online.target

          [Service]
          Type=oneshot
          ExecStart=timedatectl set-timezone Asia/Shanghai

          [Install]
          WantedBy=multi-user.target
        enabled: true
        name: custom-timezone.service
  osImageURL: ""
EOF
```







# Reference



https://access.redhat.com/solutions/5487331



