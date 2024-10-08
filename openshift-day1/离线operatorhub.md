# 目标

1. 离线ocp4.10 operator 到本地环境
2. 掌握如何在本地构建离线operator



# 离线ocp4.10 operator

## 下载所需要的工具

```

curl -LO https://mirror.openshift.com/pub/openshift-v4/amd64/clients/ocp/4.10.24/oc-mirror.tar.gz
tar zxvf oc-mirror.tar.gz -C /usr/local/bin
chmod a+x /usr/local/bin/oc-mirror 

curl -LO https://mirror.openshift.com/pub/openshift-v4/amd64/clients/ocp/4.10.24/openshift-client-linux-4.10.24.tar.gz
tar zxvf openshift-client-linux-4.10.24.tar.gz -C /usr/local/bin

yum install -y podman 
```



## 准备podman auth 文件

我们使用docker的时候，默认的auth文件是在 `~/.docker/config.json` ，如果使用了podman，同样可以使用这个文件，但是podman默认的文件是 `/run/user/0/containers/auth.json`  所以，如果使用了podman，可以将公网和本地的镜像仓库的秘钥写入`/run/user/0/containers/auth.json` 中

参考格式如下

```
{
  "auths": {
    "cloud.openshift.com": {
      "auth": "=",
      "email": ""
    },
    "quay.io": {
      "auth": "=",
      "email": ""
    },
    "registry.connect.redhat.com": {
      "auth": "",
      "email": ""
    },
    "registry.redhat.io": {
      "auth": "",
      "email": ""
    },
    "quay.ocp.example.com": {
      "auth": "=",
      "email": ""
    },
    "registry2.ocp.example.com:8443": {
      "auth": ""
    }
  }
}

```





## 下载operator index 镜像

```

# 列出来所有的4.10 operattor index 
oc mirror list operators --catalogs --version=4.10

一般有以下4个
registry.redhat.io/redhat/redhat-operator-index:v4.10
registry.redhat.io/redhat/certified-operator-index:v4.10
registry.redhat.io/redhat/community-operator-index:v4.10
registry.redhat.io/redhat/redhat-marketplace-index:v4.10



# 下载redhat-opeator-index:4.10 
podman pull --authfile /root/install/pull-secret.txt registry.redhat.io/redhat/redhat-operator-index:v4.10

# 推送到本地的镜像仓库中，之所以做这一个操作，是因为后面要多次频繁的拉取镜像，因此将这个镜像放到本地镜像仓库中可以节省一些时间
podman tag registry.redhat.io/redhat/redhat-operator-index:v4.10  registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10

podman push --remove-signatures registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10

# 列出来所有支持的 operator 
oc mirror list operators --catalog=registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10

```





## 下载operator index 到本地



```

# 或者可以下载到本地
 oc image mirror registry.redhat.io/redhat/redhat-operator-index:v4.11 file://redhat-operator-index


#  推送到 本地镜像仓库
oc image  mirror --from-dir=./redhat-index/ file://redhat-operator-index:v4.11 quay.ocp.example.com/redhat/redhat-index:v4.11
```





## 查看所有的operator 列表



```
[root@localhost data]# oc mirror list operators --catalog=registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10

WARN[0021] DEPRECATION NOTICE:
Sqlite-based catalogs and their related subcommands are deprecated. Support for
them will be removed in a future release. Please migrate your catalog workflows
to the new file-based catalog format.
NAME                                    DISPLAY NAME                                             DEFAULT CHANNEL
3scale-operator                         Red Hat Integration - 3scale                             threescale-2.12
advanced-cluster-management             Advanced Cluster Management for Kubernetes               release-2.5
amq-broker-rhel8                        Red Hat Integration - AMQ Broker for RHEL 8 (Multiarch)  7.10.x
amq-online                              Red Hat Integration - AMQ Online                         stable
amq-streams                             Red Hat Integration - AMQ Streams                        stable
amq7-interconnect-operator              Red Hat Integration - AMQ Interconnect                   1.10.x
ansible-automation-platform-operator    Ansible Automation Platform                              stable-2.2-cluster-scoped
ansible-cloud-addons-operator           Ansible Cloud Addons                                     stable-2.2-cluster-scoped
apicast-operator                        Red Hat Integration - 3scale APIcast gateway             threescale-2.12
aws-efs-csi-driver-operator             AWS EFS CSI Driver Operator                              stable
bare-metal-event-relay                  Bare Metal Event Relay                                   stable
businessautomation-operator             Business Automation                                      stable
cincinnati-operator                     OpenShift Update Service                                 v1
cluster-kube-descheduler-operator       Kube Descheduler Operator                                stable
cluster-logging                         Red Hat OpenShift Logging                                stable
clusterresourceoverride                 ClusterResourceOverride Operator                         stable
codeready-workspaces                    Red Hat CodeReady Workspaces                             latest
codeready-workspaces2                   Red Hat CodeReady Workspaces - Technical Preview         tech-preview-latest-all-namespaces
compliance-operator                     Compliance Operator                                      release-0.1
container-security-operator             Red Hat Quay Container Security Operator                 stable-3.7
costmanagement-metrics-operator         Cost Management Metrics Operator                         stable
cryostat-operator                       Cryostat Operator                                        stable
datagrid                                Data Grid                                                8.3.x
devspaces                               Red Hat OpenShift Dev Spaces                             stable
devworkspace-operator                   DevWorkspace Operator                                    fast
dpu-network-operator                    DPU Network Operator                                     stable
eap                                     JBoss EAP                                                stable
elasticsearch-operator                  OpenShift Elasticsearch Operator                         stable
external-dns-operator                   ExternalDNS Operator                                     alpha
file-integrity-operator                 File Integrity Operator                                  release-0.1
fuse-apicurito                          Red Hat Integration - API Designer                       fuse-apicurito-7.11.x
fuse-console                            Red Hat Integration - Fuse Console                       7.11.x
fuse-online                             Red Hat Integration - Fuse Online                        latest
gatekeeper-operator-product             Gatekeeper Operator                                      stable
idp-mgmt-operator-product               identity configuration management for Kubernetes         alpha
integration-operator                    Red Hat Integration                                      1.x
jaeger-product                          Red Hat OpenShift distributed tracing platform           stable
jws-operator                            JBoss Web Server Operator                                alpha
kiali-ossm                              Kiali Operator                                           stable
klusterlet-product                      Klusterlet                                               release-2.4
kubernetes-nmstate-operator             Kubernetes NMState Operator                              stable
kubevirt-hyperconverged                 OpenShift Virtualization                                 stable
local-storage-operator                  Local Storage                                            stable
loki-operator                           Loki Operator                                            candidate
mcg-operator                            NooBaa Operator                                          stable-4.10
metallb-operator                        MetalLB Operator                                         stable
mtc-operator                            Migration Toolkit for Containers Operator                release-v1.7
mtv-operator                            Migration Toolkit for Virtualization Operator            release-v2.3
multicluster-engine                     multicluster engine for Kubernetes                       stable-2.0
nfd                                     Node Feature Discovery Operator                          stable
node-healthcheck-operator               Node Health Check Operator                               candidate
node-maintenance-operator               Node Maintenance Operator                                stable
numaresources-operator                  numaresources-operator                                   4.10
ocs-operator                            OpenShift Container Storage                              stable-4.10
odf-csi-addons-operator                 CSI Addons                                               stable-4.10
odf-lvm-operator                        ODF LVM Operator                                         stable-4.10
odf-multicluster-orchestrator           ODF Multicluster Orchestrator                            stable-4.10
odf-operator                            OpenShift Data Foundation                                stable-4.10
odr-cluster-operator                    Openshift DR Cluster Operator                            stable-4.10
odr-hub-operator                        Openshift DR Hub Operator                                stable-4.10
openshift-cert-manager-operator         cert-manager Operator for Red Hat OpenShift              tech-preview
openshift-gitops-operator               Red Hat OpenShift GitOps                                 latest
openshift-pipelines-operator-rh         Red Hat OpenShift Pipelines                              pipelines-1.7
openshift-secondary-scheduler-operator  Secondary Scheduler Operator for Red Hat OpenShift       stable
openshift-special-resource-operator     Special Resource Operator                                stable
opentelemetry-product                   Red Hat OpenShift distributed tracing data collection    stable
performance-addon-operator              Performance Addon Operator                               4.10
poison-pill-manager                     Poison Pill Operator                                     stable
ptp-operator                            PTP Operator                                             stable
quay-bridge-operator                    Red Hat Quay Bridge Operator                             stable-3.7
quay-operator                           Red Hat Quay                                             stable-3.7
red-hat-camel-k                         Red Hat Integration - Camel K                            1.6.x
redhat-oadp-operator                    OADP Operator                                            stable-1.0
rh-service-binding-operator             Service Binding Operator                                 stable
rhacs-operator                          Advanced Cluster Security for Kubernetes                 latest
rhpam-kogito-operator                   RHPAM Kogito Operator                                    7.x
rhsso-operator                          Red Hat Single Sign-On Operator                          stable
sandboxed-containers-operator           OpenShift sandboxed containers Operator                  stable-1.2
serverless-operator                     Red Hat OpenShift Serverless                             stable
service-registry-operator               Red Hat Integration - Service Registry Operator          2.0.x
servicemeshoperator                     Red Hat OpenShift Service Mesh                           stable
skupper-operator                        Skupper                                                  alpha
sriov-network-operator                  SR-IOV Network Operator                                  stable
submariner                              Submariner                                               stable-0.12
tang-operator                           Tang                                                     0.0.24
topology-aware-lifecycle-manager        Topology Aware Lifecycle Manager                         stable
vertical-pod-autoscaler                 VerticalPodAutoscaler                                    stable
volsync-product                         VolSync                                                  stable
web-terminal                            Web Terminal                                             fast
windows-machine-config-operator         Windows Machine Config Operator                          stable

```



## 基于需要同步的operator，查看每一个operator的信息



```
oc-mirror list operators --catalog=registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10 --package=cluster-logging

oc-mirror list operators --catalog=registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10 --package=elasticsearch-operator 

oc-mirror list operators --catalog=registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10 --package=local-storage-operator

oc-mirror list operators --catalog=registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10 --package=ocs-operator 

oc-mirror list operators --catalog=registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10 --package=odf-csi-addons-operator

oc-mirror list operators --catalog=registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10 --package=odf-lvm-operator

oc-mirror list operators --catalog=registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10 --package=odf-multicluster-orchestrator

oc-mirror list operators --catalog=registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10 --package=odf-operator 

oc-mirror list operators --catalog=registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10 --package=advanced-cluster-management 

oc-mirror list operators --catalog=registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10 --package=rhacs-operator 
```





## 生成需要下载的operator列表

```
[root@localhost operators]# cat imageset-local.yaml
apiVersion: mirror.openshift.io/v1alpha1
kind: ImageSetConfiguration
mirror:
  operators:
    - catalog: registry2.ocp.example.com:8443/baseimage/redhat/redhat-operator-index:v4.10
      headsonly: false
      packages:
        - name: cluster-logging
          startingVersion: '5.4.3'
          channels:
            - name: stable
        - name: elasticsearch-operator
          startingVersion: '5.4.3'
          channels:
            - name: stable
        - name: local-storage-operator
          startingVersion: '4.10.0-202206291026'
          channels:
            - name: stable
        - name: ocs-operator
          startingVersion: '4.10.5'
          channels:
            - name: stable-4.10
        - name: odf-csi-addons-operator
          startingVersion: '4.10.5'
          channels:
            - name: stable-4.10
        - name: odf-lvm-operator
          startingVersion: '4.10.5'
          channels:
            - name: stable-4.10
        - name: odf-multicluster-orchestrator
          startingVersion: '4.10.5'
          channels:
            - name: stable-4.10
        - name: odf-operator
          startingVersion: '4.10.5'
          channels:
            - name: stable-4.10
        - name: advanced-cluster-management
          startingVersion: '2.5.1'
          channels:
            - name: release-2.5
        - name: rhacs-operator
          startingVersion: '3.71.0'
          channels:
            - name: latest
```



## 开始下载

执行以下命令，离线operator 

```

oc mirror --config imageset-local.yaml file://local-operators
```





## 同步operator到本地镜像仓库

说明：建议把所有的镜像都推送到同一个 repo 中，这样比较容易通过 mirror 来映射所有的镜像

```
export LOCAL_REGISTRY='registry2.ocp.example.com:8443'
export LOCAL_REPOSITORY='baseimage/ocp4'
export LOCAL_SECRET_JSON='/root/install/init-auth.json'

oc mirror --from mirror_seq1_000000.tar docker://registry2.ocp.example.com:8443/baseimage/ocp4
```



# 创建registry mirror



创建 mirror-by-tag-registries.conf 文件 

```
cat << EOF > mirror-by-tag-registries.conf
[[registry]]
  prefix = ""
  location = "registry.access.redhat.com"
  mirror-by-digest-only = false

  [[registry.mirror]]
    location = "registry2.ocp.example.com:8443/baseimage/ocp4"

[[registry]]
  prefix = ""
  location = "registry.redhat.io"
  mirror-by-digest-only = false

  [[registry.mirror]]
    location = "registry2.ocp.example.com:8443/baseimage/ocp4"

[[registry]]
  prefix = ""
  location = "registry.connect.redhat.com"
  mirror-by-digest-only = false

  [[registry.mirror]]
    location = "registry2.ocp.example.com:8443/baseimage/ocp4"
EOF
```



 生成machineconfig 文件， 分别基于worker和master 两个mcp。如果有其他的mcp，则需要创建对应的mcp 

```
REGISTRIES=`base64 -w0 mirror-by-tag-registries.conf`

cat <<EOF > mirror-by-tag-registries.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 98-worker-mirror-by-tag-registries
spec:
  config:
    ignition:
      version: 3.1.0
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,${REGISTRIES}
        filesystem: root
        mode: 420
        path: /etc/containers/registries.conf.d/098-worker-mirror-by-tag-registries.conf
---

apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: 98-master-mirror-by-tag-registries
spec:
  config:
    ignition:
      version: 3.1.0
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,${REGISTRIES}
        filesystem: root
        mode: 420
        path: /etc/containers/registries.conf.d/098-master-mirror-by-tag-registries.conf
EOF
```



生成对应的mc 配置 

```
oc apply -f mirror-by-tag-registries.yaml
```





# 配置operaothub



## 禁用所有的默认index

```
oc patch OperatorHub cluster --type json \
    -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
    
```



## 使用当前的operatorhub index

使用



## enable or disable 默认的index



```

oc edit operatorhubs/cluster

...
spec:
  disableAllDefaultSources: true
  sources:
  - disabled: true
    name: community-operators
  - disabled: true
    name: certified-operators
  - disabled: false    # 手工修改这里，可以enable默认的index 
    name: redhat-operators
  - disabled: false
    name: redhat-marketplace

```



## 配置proxy

在ocp4.10 的版本里边，离线环境operator 需要添加proxy ，否则会出现部分镜像is无法拉取的问题



```
oc edit proxy cluster


############## 

apiVersion: config.openshift.io/v1
kind: Proxy
metadata:
  creationTimestamp: "2022-08-18T05:40:37Z"
  generation: 1
  name: cluster
  resourceVersion: "607"
  uid: 2c53a99f-541f-4ed7-a369-48f75e815c42
spec:
  trustedCA:
    name: "user-ca-bundle"    # 添加 user-ca-bundle
status: {}

```





# 另一个离线operator hub 的方案

这个方案的思路大致如下

1. 在 Quay 上边创建一个同名的组织（registry.redhat.io, quay.io等)
2. 使用 `oc image mirror` 同步operator-index 镜像到本地环境，并推送到本地对应的quay repo 下
3. 使用 `oc image mirror ` 同步镜像到本地
4. 在ocp上创建 `machineconfig`, 使其自动获取对应的镜像
5. 后续如果需要添加其他的operator，重复第二步和第三步即可





## 部署 quay



## 创建MC，从本地镜像仓库获取镜像



```
cat <<EOF > mirror-registries.conf
[[registry]]
  prefix = ""
  location = "registry.redhat.io"
  mirror-by-digest-only = false

  [[registry.mirror]]
    location = "quay.ocp.example.com/registry.redhat.io"

[[registry]]
  prefix = ""
  location = "quay.io"
  mirror-by-digest-only = false

  [[registry.mirror]]
    location = "quay.ocp.example.com/quay.io"

[[registry]]
  prefix = ""
  location = "registry.connect.redhat.com"
  mirror-by-digest-only = false

  [[registry.mirror]]
    location = "quay.ocp.example.com/registry.connect.redhat.com"

[[registry]]
  prefix = ""
  location = "registry.k8s.io"
  mirror-by-digest-only = false

  [[registry.mirror]]
    location = "quay.ocp.example.com/registry.k8s.io"
EOF

REGISTRIES=`base64 -w0 mirror-registries.conf`

cat <<EOF > 099-worker-mirror-registries.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: worker
  name: 099-worker-mirror-registries
spec:
  config:
    ignition:
      version: 3.1.0
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,${REGISTRIES}
        filesystem: root
        mode: 420
        path: /etc/containers/registries.conf.d/099-mirror-registries.conf
EOF


cat <<EOF > 099-master-mirror-registries.yaml
apiVersion: machineconfiguration.openshift.io/v1
kind: MachineConfig
metadata:
  labels:
    machineconfiguration.openshift.io/role: master
  name: 099-master-mirror-registries
spec:
  config:
    ignition:
      version: 3.1.0
    storage:
      files:
      - contents:
          source: data:text/plain;charset=utf-8;base64,${REGISTRIES}
        filesystem: root
        mode: 420
        path: /etc/containers/registries.conf.d/099-mirror-registries.conf
EOF

oc apply -f 099-worker-mirror-registries.yaml
oc apply -f 099-master-mirror-registries.yaml

```





## 同步镜像

使用以下脚本

### 准备工作

1. pull secret 文件
2. 下载，安装 grpcurl
3. 

### 本地启动operator-index 镜像

```
podman run  --authfile ~/install/pull-secret.txt -p50051:50051 -it registry.redhat.io/redhat/redhat-operator-index:v4.12
```



### list  operator



```
#!/usr/bin/env bash

grpcurl -plaintext localhost:50051  api.Registry.ListPackages | jq -r .name | sort
```



### list images

执行以下脚本，list 选择的 package 都有哪些 image

```
cat list-image.sh

package=$1

#channel="stable"

default_channel=$(grpcurl -d '{"name":"'${package}'"}' -plaintext localhost:50051 api.Registry.GetPackage | jq -r .defaultChannelName)

cvs=$(grpcurl -d '{"name":"'${package}'"}' -plaintext localhost:50051 api.Registry.GetPackage | jq -r '.channels[]|select(.name == "'${default_channel}'").csvName')

data='{"pkgName": "'${package}'", "channelName": "'${default_channel}'", "csvName": "'${cvs}'"}'

grpcurl -d "$data" -plaintext localhost:50051 api.Registry.GetBundle | jq -r .bundlePath

grpcurl -d "$data" -plaintext localhost:50051 api.Registry.GetBundle | jq -r .csvJson | jq -r .spec.relatedImages[].image
```



### 同步 image 到本地

> 说明： images_file 是包含 images列表的文件
>
> 

```
cat mirror-image.sh 

images_file=$1
echo "images_file: "$images_file

from_redhat=${from_redhat:-"true"}

auth_file='/root/install/all-secret.json'

for line in `cat $images_file`;do
  redhat_domain=$(echo $line | awk -F '/' '{print $1}')
  if [[ $from_redhat == "true" ]]; then
    src_image_name=$line
  else
    src_image_name=$(echo $line | sed "s/${redhat_domain}/${src_registry}/g")
  fi
  dest_image_name=$(echo $line | awk -F '@' '{print $1} '| sed "s/${redhat_domain}//g")
  sha=$(echo $line | awk -F '@' '{print $2} ')
  tag=$(echo $line | awk -F ':' '{print $2}')
  if [[ "$sha" == "sha256"* ]]; then
    tag=${tag:0:8}
    dest_image_name=$dest_image_name:$tag
  fi

  echo "========================================="
  echo "oc image mirror $src_image_name $dest_image_name -a $auth_file  --keep-manifest-list=true --filter-by-os='.*' --insecure=true"
  echo "========================================="
  oc image mirror $src_image_name file:/$dest_image_name -a $auth_file  --keep-manifest-list=true --filter-by-os='.*'
  echo ""
done

```





### 同步 operator index 镜像到本地



```

oc image mirror registry.redhat.io/redhat/redhat-marketplace-index:v4.12 file://redhat/redhat-marketplace-index -a /root/install/mysecret.json --keep-manifest-list=true --filter-by-os='.*'
```



### 推送镜像到本地quay

```

oc image mirror -a /root/install/mysecret.json file://redhat/redhat-operator-index:v4.12  quay2.ocp.example.com/registry.redhat.io/redhat/redhat-operator-index:v4.12 --keep-manifest-list=true --filter-by-os='.*'
```



### 推送本地operator 镜像到镜像仓库

> 说明： 后面使用的时候有两个地方需要修改
>
> 1. Auth_file 路径
> 2. dest_registry 路径
>
> 注意： 下面最关键的33行，被注释掉了，可以先通过上边打印出来的结果来看一下 命令是否正确。确认命令正确后再真正执行

```
cat upload_images.sh
=============


#!/usr/bin/env bash

images_file=$1
echo "images_file: "$images_file

dest_registry="quay2.ocp.example.com/registry.redhat.io"
from_redhat=${from_redhat:-"true"}

auth_file='/root/install/all-secret.json'

for line in `cat $images_file`;do
  redhat_domain=$(echo $line | awk -F '/' '{print $1}')
  if [[ $from_redhat == "true" ]]; then
    src_image_name=$(echo $line | sed "s/${redhat_domain}//g")
  else
    src_image_name=$(echo $line | sed "s/${redhat_domain}/${src_registry}/g")
  fi
  dest_image_name=$(echo $line | awk -F '@' '{print $1} '| sed "s#${redhat_domain}#${dest_registry}#g")
  sha=$(echo $line | awk -F '@' '{print $2} ')
  tag=$(echo $line | awk -F ':' '{print $2}')
  if [[ "$sha" == "sha256"* ]]; then
    tag=${tag:0:8}
    dest_image_name=$dest_image_name:$tag
  fi

  echo "========================================="
  echo "oc image mirror file:/$src_image_name $dest_image_name -a $auth_file  --keep-manifest-list=true --filter-by-os='.*' "
  echo "========================================="
  ## oc image mirror file:/$src_image_name $dest_image_name -a $auth_file  --keep-manifest-list=true --filter-by-os='.*'
  echo ""
done

=============

bash upload_images.sh <images_file>


```



# 使用本地operator

## 禁用所有operatorhub

```
oc patch OperatorHub cluster --type json \
    -p '[{"op": "add", "path": "/spec/disableAllDefaultSources", "value": true}]'
```



## 创建新的 catalogsource

创建 catalogSource-redhat-operator-index.yaml 

```
# cat catalogSource-redhat-operator-index.yaml 

apiVersion: operators.coreos.com/v1alpha1
kind: CatalogSource
metadata:
  name: local-redhat-operator-index
  namespace: openshift-marketplace
spec:
  sourceType: grpc
  image: harbor.ocp4.example.com:8443/operatorhub/redhat/redhat-operator:v4.15
  displayName: Local Red Hat Operators
  publisher: Red Hat
```





## 创建新的imageContentSourcePolicy

> 注意： 创建新的 imageContentSourcePolicy后，

```
# cat imageContentSourcePolicy.yaml 

apiVersion: operator.openshift.io/v1alpha1
kind: ImageContentSourcePolicy
metadata:
  name: redhat-operator-index-415
spec:
  repositoryDigestMirrors:
  - mirrors:
    - harbor.ocp4.example.com:8443/operatorhub
    source: registry.redhat.io
```





# 基于选择的operator离线operator hub

有时候，我们只需要交付特定的operator，此时可以只准备特定的镜像出来，并且创建不同的sourcecatalog



