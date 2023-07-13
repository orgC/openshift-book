

# 目标

1. 在linux 环境上完成测试demo
2. 





# env setup



## install butane



```
dnf install -y butane

```



## 生成本地key

```
ssh-keygen -t rsa -b 4096 -N '' -f ~/.ssh/id_rsa
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa

cat /root/.ssh/id_rsa.pub
```



## 生成点火文件

```
example.bu

ID_RSA=`cat /root/.ssh/id_rsa.pub`

cat <<EOF > example.bu
variant: fcos
version: 1.4.0
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - ${ID_RSA}
EOF

执行以下命令生成点火文件
butane --pretty --strict example.bu > example.ign

生成的文件如下
cat example.ign| jq
{
  "ignition": {
    "version": "3.3.0"
  },
  "passwd": {
    "users": [
      {
        "name": "core",
        "sshAuthorizedKeys": [
          "ssh-rsa AAAA..."
        ]
      }
    ]
  }
}
```



## 导入fcos 镜像

本地已经下载了fcos ova 镜像



```
FCOS_OVA='fedora-coreos-38.20230609.3.0-vmware.x86_64.ova'
LIBRARY='fcos-images'
TEMPLATE_NAME='fcos-38.20230609.3.0'

govc library.create -ds=hdd "${LIBRARY}"   # 如果有多个ds，需要指定ds
govc library.import -n "${TEMPLATE_NAME}" "${LIBRARY}" "${FCOS_OVA}"
```



## 创建一个新的vm



### 使用DHCP 自动分配IP



```
CONFIG_ENCODING='base64'
CONFIG_ENCODED=$(cat example.ign | base64 -w0 -)

VM_NAME='fcos-node01'
govc library.deploy "${LIBRARY}/${TEMPLATE_NAME}" "${VM_NAME}"
govc vm.change -vm "${VM_NAME}" -e "guestinfo.ignition.config.data.encoding=${CONFIG_ENCODING}"
govc vm.change -vm "${VM_NAME}" -e "guestinfo.ignition.config.data=${CONFIG_ENCODED}"


# 启动节点
govc vm.info -e "${VM_NAME}"
govc vm.power -on "${VM_NAME}"
```



### 在启动时配置网络

创建一个vm，指定该VM的网络配置

```
LIBRARY='fcos-images'
TEMPLATE_NAME='fcos-38.20230609.3.0'

CONFIG_ENCODING='base64'
CONFIG_ENCODED=$(cat example.ign | base64 -w0 -)

VM_NAME='fcos-node02'
IFACE='ens192'
IPCFG="ip=192.168.3.42::192.168.3.1:255.255.255.0:${VM_NAME}:${IFACE}:off"

govc library.deploy "${LIBRARY}/${TEMPLATE_NAME}" "${VM_NAME}"
govc vm.change -vm "${VM_NAME}" -e "guestinfo.ignition.config.data.encoding=${CONFIG_ENCODING}"
govc vm.change -vm "${VM_NAME}" -e "guestinfo.ignition.config.data=${CONFIG_ENCODED}"
govc vm.change -vm "${VM_NAME}" -e "guestinfo.afterburn.initrd.network-kargs=${IPCFG}"
govc vm.info -e "${VM_NAME}"
govc vm.power -on "${VM_NAME}"

```



### 清理环境 

执行以下命令清理环境

```
VM_NAME='fcos-node02'
govc vm.destroy ${VM_NAME}
rm -rf ~/.ssh/known_hosts
```



## 设置 hostname

设置 hostname



```
ID_RSA=`cat /root/.ssh/id_rsa.pub`
HOSTNAME='fcos-node02.ocp.example.com'

cat <<EOF > example.bu
variant: fcos
version: 1.4.0
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - ${ID_RSA}
storage:
  files:
    - path: /etc/hostname
      mode: 0644
      contents:
        inline: ${HOSTNAME}
EOF

butane --pretty --strict example.bu > example.ign

LIBRARY='fcos-images'
TEMPLATE_NAME='fcos-38.20230609.3.0'

CONFIG_ENCODING='base64'
CONFIG_ENCODED=$(cat example.ign | base64 -w0 -)

VM_NAME='fcos-node02'
IFACE='ens192'
IPCFG="ip=192.168.3.42::192.168.3.1:255.255.255.0:${VM_NAME}:${IFACE}:off"

govc library.deploy "${LIBRARY}/${TEMPLATE_NAME}" "${VM_NAME}"
govc vm.change -vm "${VM_NAME}" -e "guestinfo.ignition.config.data.encoding=${CONFIG_ENCODING}"
govc vm.change -vm "${VM_NAME}" -e "guestinfo.ignition.config.data=${CONFIG_ENCODED}"
govc vm.change -vm "${VM_NAME}" -e "guestinfo.afterburn.initrd.network-kargs=${IPCFG}"
govc vm.info -e "${VM_NAME}"
govc vm.power -on "${VM_NAME}"

```



## kernel tuning



```

ID_RSA=`cat /root/.ssh/id_rsa.pub`
HOSTNAME='fcos-node02.ocp.example.com'

cat <<EOF > example.bu
variant: fcos
version: 1.4.0
passwd:
  users:
    - name: core
      ssh_authorized_keys:
        - ${ID_RSA}
storage:
  files:
    - path: /etc/hostname
      mode: 0644
      contents:
        inline: ${HOSTNAME}
    - path: /etc/sysctl.d/90-sysrq.conf
      contents:
        inline: |
          kernel.sysrq = 0
EOF

butane --pretty --strict example.bu > example.ign

LIBRARY='fcos-images'
TEMPLATE_NAME='fcos-38.20230609.3.0'

CONFIG_ENCODING='base64'
CONFIG_ENCODED=$(cat example.ign | base64 -w0 -)

VM_NAME='fcos-node02'
IFACE='ens192'
IPCFG="ip=192.168.3.42::192.168.3.1:255.255.255.0:${VM_NAME}:${IFACE}:off"

govc library.deploy "${LIBRARY}/${TEMPLATE_NAME}" "${VM_NAME}"
govc vm.change -vm "${VM_NAME}" -e "guestinfo.ignition.config.data.encoding=${CONFIG_ENCODING}"
govc vm.change -vm "${VM_NAME}" -e "guestinfo.ignition.config.data=${CONFIG_ENCODED}"
govc vm.change -vm "${VM_NAME}" -e "guestinfo.afterburn.initrd.network-kargs=${IPCFG}"
govc vm.info -e "${VM_NAME}"
govc vm.power -on "${VM_NAME}"

```



