# 安装 openshift-local-storage



```

cat <<EOF | oc apply -f -
apiVersion: v1
kind: Namespace
metadata:
 name: openshift-local-storage
spec: {}
EOF
```





安装odf需要有额外的一块硬盘，为计划安装odf的节点打上label

```
oc label node odf1.test1.ocp.example.com cluster.ocs.openshift.io/openshift-storage=''
oc label node odf2.test1.ocp.example.com cluster.ocs.openshift.io/openshift-storage=''
oc label node odf3.test1.ocp.example.com cluster.ocs.openshift.io/openshift-storage=''
oc label node odf4.test1.ocp.example.com cluster.ocs.openshift.io/openshift-storage=''
oc label node odf5.test1.ocp.example.com cluster.ocs.openshift.io/openshift-storage=''
```





## 创建 LocalVolumeDiscovery 对象



```

cat <<EOF | oc apply -f -
apiVersion: local.storage.openshift.io/v1alpha1
kind: LocalVolumeDiscovery
metadata:
 name: auto-discover-devices
 namespace: openshift-local-storage
spec:
 nodeSelector:
   nodeSelectorTerms:
     - matchExpressions:
       - key: cluster.ocs.openshift.io/openshift-storage
         operator: In
         values:
           - ""
EOF
```



## 创建 LocalVolumeSet 对象

```
cat << EOF > localvolumeset.yaml
apiVersion: local.storage.openshift.io/v1alpha1
kind: LocalVolumeSet
metadata:
 name: local-block
 namespace: openshift-local-storage
spec:
 nodeSelector:
   nodeSelectorTerms:
     - matchExpressions:
         - key: cluster.ocs.openshift.io/openshift-storage
           operator: In
           values:
             - ""
 storageClassName: localblock
 volumeMode: Block
 fstype: ext4
 maxDeviceCount: 1
 deviceInclusionSpec:
   deviceTypes:
   - disk
   deviceMechanicalProperties:
   - NonRotational
EOF

### 
oc create -f localvolumeset.yaml
```

稍等一下，会创建新的PV 

![image-20221101172741104](./odf-install.assets/image-20221101172741104.png)





#  安装ODF



## 安装operator



![image-20221101172938283](./odf-install.assets/image-20221101172938283.png)

ODF operator 部署成功

![image-20221101173418596](./odf-install.assets/image-20221101173418596.png)







```

cat << EOF > storagecluster.yaml
apiVersion: ocs.openshift.io/v1
kind: StorageCluster
metadata:
 name: ocs-storagecluster
 namespace: openshift-storage
spec:
 manageNodes: false
 resources:
   mds:
     limits:
       cpu: "3"
       memory: "8Gi"
     requests:
       cpu: "3"
       memory: "8Gi"
 monDataDirHostPath: /var/lib/rook
 storageDeviceSets:
 - count: 1  
   dataPVCTemplate:
     spec:
       accessModes:
       - ReadWriteOnce
       resources:
         requests:
           storage: "100Gi"  
       storageClassName: localblock
       volumeMode: Block
   name: ocs-deviceset
   placement: {}
   portable: false
   replica: 3
   resources:
     limits:
       cpu: "2"
       memory: "5Gi"
     requests:
       cpu: "2"
       memory: "5Gi"
EOF

# 执行命令，创建odf对象

oc create -f storagecluster.yaml

```











# Reference



https://access.redhat.com/articles/5692201



