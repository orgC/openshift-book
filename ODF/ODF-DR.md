

# 目标

做一个 ODF DR 的demo



# 说明



## 概念



### Metro-DR

Metro-DR 可确保在数据中心出现问题时保持业务的连续性，并不会造成数据丢失。在公有云中，它们类似于防止可用性区域失败。

###  Regional-DR

区域 DR 可以在一个地理区域出现问题时确保业务的连续性（在可以接受一些可预测数量的数据丢失的情况下）。在公有云中，它们类似于防止区域故障。

### 使用扩展集群进行灾难恢复

扩展集群解决方案可确保在单一 OpenShift 集群中通过基于 OpenShift Data Foundation 的同步复制，在具有低延迟和一个仲裁节点的两个数据中心间扩展，且无数据丢失灾难恢复保护。



### RPO（ecovery Point Objective）

是一种衡量持久性数据备份或快照的频率。实际上，RPO 表示在中断后将丢失或需要重新输入的数据量。

### RTO（Recovery Time Objective）

是企业可以容忍的停机时间。RTO 回答了这个问题，"在收到业务中断通知后，我们的系统需要多久才能恢复？"





# 试验环境

OCP4.11 



本试验参考该[教程](https://red-hat-storage.github.io/ocs-training/training/ocs4/odf411-multisite-ramen.html#_verify_managed_clusters_have_non_overlapping_networks)





# 准备工作



## 安装ACM



![image-20230627163349077](./ODF-DR.assets/image-20230627163349077.png)



### 创建MultiClusterHub



![image-20230627163607700](./ODF-DR.assets/image-20230627163607700.png)

```
apiVersion: operator.open-cluster-management.io/v1
kind: MultiClusterHub
metadata:
  name: multiclusterhub
  namespace: open-cluster-management
spec:
  disableHubSelfManagement: true
```







## 安装 OCP1 集群

通过ACM安装OCP1

![image-20230627164908695](./ODF-DR.assets/image-20230627164908695.png)

需要安装ODF，因此需要选择内存大一些的Worker节点

![image-20230627165005907](./ODF-DR.assets/image-20230627165005907.png)



规划容器网络IP

![image-20230627165111660](./ODF-DR.assets/image-20230627165111660.png)



![image-20230627165201344](./ODF-DR.assets/image-20230627165201344.png)





## 安装OCP2 集群



![image-20230627165305125](./ODF-DR.assets/image-20230627165305125.png)



![image-20230627165405081](./ODF-DR.assets/image-20230627165405081.png)

与ocp1 的网络区别开来

![image-20230627165443603](./ODF-DR.assets/image-20230627165443603.png)





## 安装ODF



![image-20230913085222779](./ODF-DR.assets/image-20230913085222779.png)



![image-20230913085724691](./ODF-DR.assets/image-20230913085724691.png)





![image-20230627230623808](./ODF-DR.assets/image-20230627230623808.png)



![image-20230627230637063](./ODF-DR.assets/image-20230627230637063.png)

![image-20230627230648120](./ODF-DR.assets/image-20230627230648120.png)

![image-20230627230703722](./ODF-DR.assets/image-20230627230703722.png)



### 验证安装成功

分别在ocp1 和 ocp2上验证安装ODF成功

```
# 检查ODF状态
oc get storagecluster -n openshift-storage ocs-storagecluster -o jsonpath='{.status.phase}{"\n"}'

# 检查 Multi-Cluster Gateway（MCG）状态
oc get noobaa -n openshift-storage noobaa -o jsonpath='{.status.phase}{"\n"}'

```



![image-20230627152417743](./ODF-DR.assets/image-20230627152417743.png)



## 验证容器网络IP没有重叠

由于使用到了submariner来进行集群间的连接，所以需要保证集群之间的网络不能重叠，通过以下命令进行检查

ocp1 

```
[root@ocp1-bastion-node ~]# oc get networks.config.openshift.io cluster -o json | jq .spec


{
  "clusterNetwork": [
    {
      "cidr": "10.1.0.0/16",
      "hostPrefix": 23
    }
  ],
  "externalIP": {
    "policy": {}
  },
  "networkType": "OpenShiftSDN",
  "serviceNetwork": [
    "10.2.0.0/16"
  ]
}
```

ocp2 

```
[root@ocp2-bastion-node ~]# oc get networks.config.openshift.io cluster -o json | jq .spec

{
  "clusterNetwork": [
    {
      "cidr": "10.4.0.0/16",
      "hostPrefix": 23
    }
  ],
  "externalIP": {
    "policy": {}
  },
  "networkType": "OpenShiftSDN",
  "serviceNetwork": [
    "10.5.0.0/16"
  ]
}
```



## 通过submariner 连接两个集群



### 创建新的 clusterset 

![image-20230627151551305](./ODF-DR.assets/image-20230627151551305.png)

![image-20230627151629038](./ODF-DR.assets/image-20230627151629038.png)

![image-20230627151643453](./ODF-DR.assets/image-20230627151643453.png)

![image-20230627151657158](./ODF-DR.assets/image-20230627151657158.png)



### 安装submariner 插件



![image-20230627152010425](./ODF-DR.assets/image-20230627152010425.png)

![image-20230627152059173](./ODF-DR.assets/image-20230627152059173.png)



![image-20230627152124225](./ODF-DR.assets/image-20230627152124225.png)



![image-20230627152153508](./ODF-DR.assets/image-20230627152153508.png)







## 安装 ODF Multicluster Orchestrator Operator



在  ACM Hub 集群上 安装  ODF Multicluster Orchestrator



![image-20230627153015578](./ODF-DR.assets/image-20230627153015578.png)



安装 ODF Multicluster Orchestrator的时候，会自动安装Openshift DR Hub Operator 

![image-20230627215959985](./ODF-DR.assets/image-20230627215959985.png)



```
[lab-user@bastion ~]$ oc get pods -n openshift-operators
NAME                                        READY   STATUS    RESTARTS   AGE
odf-multicluster-console-789b7c7f4b-2n6tr   1/1     Running   0          2m38s
odfmo-controller-manager-65b46797bb-5h2ds   1/1     Running   0          2m38s
ramen-hub-operator-799f695d5c-tf8z5         2/2     Running   0          2m34s
```



## 在S3之间配置 SSL 访问



在ocp1集群执行 以下命令，获取 ingress 证书

```
oc get cm default-ingress-cert -n openshift-config-managed -o jsonpath="{['data']['ca-bundle\.crt']}" > primary.crt
```



在 ocp2集群执行以下命令，获取ingress整数

```
oc get cm default-ingress-cert -n openshift-config-managed -o jsonpath="{['data']['ca-bundle\.crt']}" > secondary.crt
```



将上边输出的内容copy出来，按照以下格式进行填写

```
apiVersion: v1
data:
  ca-bundle.crt: |
    -----BEGIN CERTIFICATE-----
    <copy contents of cert1 from primary.crt here>
    -----END CERTIFICATE-----

    -----BEGIN CERTIFICATE-----
    <copy contents of cert2 from primary.crt here>
    -----END CERTIFICATE-----

    -----BEGIN CERTIFICATE-----
    <copy contents of cert3 primary.crt here>
    -----END CERTIFICATE----

    -----BEGIN CERTIFICATE-----
    <copy contents of cert1 from secondary.crt here>
    -----END CERTIFICATE-----

    -----BEGIN CERTIFICATE-----
    <copy contents of cert2 from secondary.crt here>
    -----END CERTIFICATE-----

    -----BEGIN CERTIFICATE-----
    <copy contents of cert3 from secondary.crt here>
    -----END CERTIFICATE-----
kind: ConfigMap
metadata:
  name: custom-ca-bundle
  namespace: openshift-config
```

生成cm-clusters-crt.yaml 文件， 分别在 hub集群，ocp1，ocp2上执行以下命令 `oc create -f cm-clusters-crt.yaml`

```
apiVersion: v1
data:
  ca-bundle.crt: |
    -----BEGIN CERTIFICATE-----
    MIIDiTCCAnGgAwIBAgIIWJk/ua0Xq08wDQYJKoZIhvcNAQELBQAwJjEkMCIGA1UE
    AwwbaW5ncmVzcy1vcGVyYXRvckAxNjg3ODU2NTU4MB4XDTIzMDYyNzA5MDIzOVoX
    DTI1MDYyNjA5MDI0MFowNDEyMDAGA1UEAwwpKi5hcHBzLm9jcDEucnA2ZmIuc2Fu
    ZGJveDI1OTMub3BlbnRsYy5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
    AoIBAQCe4ywhBN05SMsPPaMOB7kGARqsE25Q6twuLZPJMoM99xDlgGE4EgM1ckzY
    95kagiXMOs4abPEJHkOTDBBCfTj1NcHwpJNzqBfW2j30LSRPGrDkVSlB+M7ZrDju
    mE4Yw5KOvOjABqTetazHNXInNipDNUhxvdD5EHs+WRHuMsxhcQ2R4WHUBAjeoUNH
    ohnTRKF9w8KA69X4KbQprbm4wcTdIRT88+XVIcyVw7Edy8eoZXZNSbNqQfon27Fl
    e4tL52R0IjV4F6ufPQv4KDBm08DhqJ7CGppNPJkKiav3GnzB1gqkj2pQtjAm+qv/
    /YF6QRAnXlLNDPV+++0WRHCaxCAdAgMBAAGjgawwgakwDgYDVR0PAQH/BAQDAgWg
    MBMGA1UdJQQMMAoGCCsGAQUFBwMBMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFGDK
    uovm74qkWG6YgZTE6mz8xnPAMB8GA1UdIwQYMBaAFLxhH154S9EOIsnwBu6EU/FG
    Axq/MDQGA1UdEQQtMCuCKSouYXBwcy5vY3AxLnJwNmZiLnNhbmRib3gyNTkzLm9w
    ZW50bGMuY29tMA0GCSqGSIb3DQEBCwUAA4IBAQARdi3u6Tp1RRRfCrX1WNCenNA3
    b2szpunFMrFE8Oe784X9zJkCSQo29fKi+yMUH39Fc3KOMayslliofs5NvL5kD3cD
    EaM9x/D0p2uSj68jYLZ4sRVUCQuvrSB92biwdtaFdZ6A3INaCqFAPiZbfHhFYKVg
    2HF5cKIs2G6YAKdirfyebtnaasFEOrGk/jzAamEgf/mfK1/atsNbD2phXcchkfkV
    ihJUfcv5wByt1TcnE2YZoO5S86UxTX3RFg92/66/4h51o++NpSfrs+SbaDVjLCJE
    g7iQrHVtv8YJ9vjaf1Tb2TXdjB8bKqcUOH546qs1TE8poYqUm1kboKVUXNRv
    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----
    MIIDDDCCAfSgAwIBAgIBATANBgkqhkiG9w0BAQsFADAmMSQwIgYDVQQDDBtpbmdy
    ZXNzLW9wZXJhdG9yQDE2ODc4NTY1NTgwHhcNMjMwNjI3MDkwMjM4WhcNMjUwNjI2
    MDkwMjM5WjAmMSQwIgYDVQQDDBtpbmdyZXNzLW9wZXJhdG9yQDE2ODc4NTY1NTgw
    ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDCEUoKxXD4kZcA8MEsQKRE
    ROd9W9KSYlati/Dtv/UJlS3uxJSKvM69VESXO4qTp6EI7ILCDNocfS3/NEvExJuU
    NZsFFqffkOs71aCPkFvTtN9BT1sAhIvzrKJO+W9nY5RHHoRT/nFQLpNJRCytgkLK
    vREVbd28wObu2naeuQ7Cq0bEBXmSHnEKEDflkoTEDjCZSmYq9Ct8lOgsi0dLsXD7
    1QRrNeNC438pgHAs76ya8512wMsg5qEnKJLcLx4mGU71Fo2Q8Uzx1zNCplLARcj2
    3l+CmLCxaW8ajBjfuzIN8OTujJae7qvODDNmdlxoKAyn91IAWOMZD9Wo1itmq7nf
    AgMBAAGjRTBDMA4GA1UdDwEB/wQEAwICpDASBgNVHRMBAf8ECDAGAQH/AgEAMB0G
    A1UdDgQWBBS8YR9eeEvRDiLJ8AbuhFPxRgMavzANBgkqhkiG9w0BAQsFAAOCAQEA
    Bco4qMdBWD4NQcdnqwpuc12NoCeozYu0LqfFsX7eQHMXeGj8Z27pnn9IHLWYSzwD
    rv/4ZlOHxk1JGKOtXiKQPnAxi2iS4ftcVz7Nf6VQ9EpjW7q1ck+i/4Z3b488XoGN
    L5B5Hicpuep8RFRYKP2PpS2oo1fRiuL+Tu2ItDESqe/lsfwbaI+jD3WsZVtTdNFm
    xpka3GlDLZMklbJGkf5Or8eZ6bsqywTRB4AiasNmeVezUfbljlrH5S1+t8ou6GP2
    nucsPLMrm+V1S/InY1MY7vDedRObz8l7pc6omAgIXM6vVSdrJAVx9//vGSbmhOWL
    EyNGGMVYQU/GndG4xrfYhg==
    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----
    MIIDiTCCAnGgAwIBAgIIC1KGEaBYccYwDQYJKoZIhvcNAQELBQAwJjEkMCIGA1UE
    AwwbaW5ncmVzcy1vcGVyYXRvckAxNjg3ODU2ODA5MB4XDTIzMDYyNzA5MDY0OVoX
    DTI1MDYyNjA5MDY1MFowNDEyMDAGA1UEAwwpKi5hcHBzLm9jcDIucnA2ZmIuc2Fu
    ZGJveDI1OTMub3BlbnRsYy5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEK
    AoIBAQDBWNN2XwfHhWtZV+tW2RrWhovD4jZ6N+9oMrw3rtN+8kmLJkX5UUzowiLf
    L7eYZ6Pz3a0XnZW3zO3lbdEFZyf6zaN/M4pAL74/oiTuE5LyhVghKNWYvJToqYl5
    73r2HBx4fJ7HbU29nJ/OAW+sY3Cqvs/aewnn1b50QPra835Hscti2LonX44qjSE9
    rlHTld4UVeRnG4YRx8/2BCzjOqCMbpf7Po5aSgqUYb1ljuz4mLvzGfFpsEWo6mp6
    tvncXknblghRia8Zw9QCTDHqb2+kBZTc6WBRkPmsRYk6JQWocFbKKKmhc6YNbRbg
    y+XvrpCDc00E2NTMZd/yCEwTUBE3AgMBAAGjgawwgakwDgYDVR0PAQH/BAQDAgWg
    MBMGA1UdJQQMMAoGCCsGAQUFBwMBMAwGA1UdEwEB/wQCMAAwHQYDVR0OBBYEFEsN
    t75rsn4bx/AzgvIuzHlTeTNuMB8GA1UdIwQYMBaAFFL4Il/B3PARKxn89Qq6C2qJ
    m7q7MDQGA1UdEQQtMCuCKSouYXBwcy5vY3AyLnJwNmZiLnNhbmRib3gyNTkzLm9w
    ZW50bGMuY29tMA0GCSqGSIb3DQEBCwUAA4IBAQBCfHsa7XJ5MEN4UAnAMMIh2Jq0
    UMeQIAq87hi8rZcom1UfStlX45PsaPxO7qP7BjhH6R5IcaMAbWfAK13xZeaJ9fWx
    7q3tMHPzWQPDcBTEkanaMWdK9FTt3Y9XdGYMvcrL4FOSbKdjxpdxM0dy7l/vPj23
    X+U6xa0YtHLpVviHyNByZme8aYzJrN2+weywZr9KIZW4ANDn9xl6LHK9vjuRX5Oj
    YjDN+RR0baSg0YH9BhEQG0UbZk8mkAkUL6mmqHyXpVsRgZKu09huzHIDYJXu0Hi5
    p2kHYirQVSyfhAAANJt6hAeoly8hZ3pZVjYN7FeL9r+z6OPztvdZMI0yBUjh
    -----END CERTIFICATE-----
    -----BEGIN CERTIFICATE-----
    MIIDDDCCAfSgAwIBAgIBATANBgkqhkiG9w0BAQsFADAmMSQwIgYDVQQDDBtpbmdy
    ZXNzLW9wZXJhdG9yQDE2ODc4NTY4MDkwHhcNMjMwNjI3MDkwNjQ4WhcNMjUwNjI2
    MDkwNjQ5WjAmMSQwIgYDVQQDDBtpbmdyZXNzLW9wZXJhdG9yQDE2ODc4NTY4MDkw
    ggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC03jl7GdSLMYjjpnwPr6SE
    6hEu4/wUuN7znHXTDnZQ2XvaGAtTJlrAd7LkHDV3puV2+cLrkWL9m1ie6hPWMDGE
    uBXfv+tjlbJlpLAiuwuONVvNkUhaALufkg0CFZtB4ByQnwTUktL1Olqjdmdbv8lZ
    ltaF7iKwOk0y/e1KwK/YHJFICOCLa6Qegc60+vYUFuwzcZWI80s5Ffm5kbbI/qNW
    APK/AnybQBNY/b+9i34WbD3nGYc3feU9ZpkEgiqqEJPEkr1WPPJsAX+WDWmkJotV
    dtJA21Oj04O1iT/tgbobHxn/0X1+3h+Owk7QV+04vBTuDC1j6wZAGOCcBG/OmW7R
    AgMBAAGjRTBDMA4GA1UdDwEB/wQEAwICpDASBgNVHRMBAf8ECDAGAQH/AgEAMB0G
    A1UdDgQWBBRS+CJfwdzwESsZ/PUKugtqiZu6uzANBgkqhkiG9w0BAQsFAAOCAQEA
    c4WLDzKmZkpe03RPaWyvPUCU7/24oGFQyT8Dg+NPNDo/8ko3lhFSLrMvum+CjGlQ
    Qd0kSKbSrD1Qo+aYBO5sfgclYqr+GxM4KyCLdUa8wBxTketBuT5JPGnOPghku5Ix
    GxOuaPbgF6dsQ8b0RULk4WumL6CXnjeNQIH1Jxm4ukT3osPDlQ/jU6UQ956C/Jfw
    pbsOrWnuY5wcT9wCmbN7mjS7ic3bbSynA1g80UCChp8UMUevbM50el7N3DYUsKn8
    /85KTxou/Cip/j65UN0icciNfcCDRklzXCrWtiyD/KFRNowODMBx375B7ps4tynN
    i3uVpBaFnQU6K+9Btq+j6A==
    -----END CERTIFICATE-----
kind: ConfigMap
metadata:
  name: custom-ca-bundle
  namespace: openshift-config
```



在 hub，ocp1  和 ocp2 上执行以下命令，为三个集群设置proxy

```
oc patch proxy cluster --type=merge  --patch='{"spec":{"trustedCA":{"name":"custom-ca-bundle"}}}'
```





## 打开 Multicluster Web Console

在 hub 节点上执行以下操作：

打开 **Administration** → **Cluster Settings** → **Configuration** → **FeatureGate**  ， 打开yaml，按照以下内容修改

```
[...]
spec:
  featureSet: TechPreviewNoUpgrade
```



![image-20230627223921579](./ODF-DR.assets/image-20230627223921579.png)



![image-20230627224032440](./ODF-DR.assets/image-20230627224032440.png)

此时打开ACM console，可以看到增加了一项

![image-20230627225721950](./ODF-DR.assets/image-20230627225721950.png)



## 在 hub cluster 上 创建 Data Policy



![image-20230915104535381](./ODF-DR.assets/image-20230915104535381.png)



当创建DRpolicy后， 会执行以下动作



- Create a bootstrap token and exchanges this token between the managed clusters.
- Enable mirroring for the default `CephBlockPool` on each managed clusters.
- Create a **VolumeReplicationClass** on the **Primary managed cluster** and the **Secondary managed cluster** for the replication interval in the DRPolicy.
- An object bucket created (using MCG) on each managed cluster for storing **PVC** and **PV** metadata.
- A **Secret** created in the `openshift-operators` project on the **Hub cluster** for each new object bucket that has the base64 encoded access keys.
- The `ramen-hub-operator-config` **ConfigMap** on the **Hub cluster** is modified with `s3StoreProfiles` entries.
- The `OpenShift DR Cluster` operator will be deployed on each managed cluster in the `openshift-dr-system` project.
- The object buckets **Secrets** on the **Hub cluster** in the project `openshift-operators` will be copied to the managed clusters in the `openshift-dr-system` project.
- The `s3StoreProfiles` entries will be copied to the managed clusters and used to modify the `ramen-dr-cluster-operator-config` **ConfigMap** in the `openshift-dr-system` project.





![image-20230915104802287](./ODF-DR.assets/image-20230915104802287.png)

在HUB节点上执行命令，查看 DR 创建结果

```
[root@bastion-test3 odf-dr]# oc get drpolicy ocp4-ocp5-1m -o jsonpath='{.status.conditions[].reason}{"\n"}'
Succeeded

[root@bastion-test3 odf-dr]# oc get drclusters
NAME    AGE
test4   5m6s
test5   5m6s

```



在 **Primary managed cluster**  和 **Secondary managed cluster** 上执行 

```
[root@bastion-test4 odf-dr]# oc get csv,pod -n openshift-dr-system
NAME                                                                            DISPLAY                         VERSION        REPLACES                             PHASE
clusterserviceversion.operators.coreos.com/odr-cluster-operator.v4.12.7-rhodf   Openshift DR Cluster Operator   4.12.7-rhodf   odr-cluster-operator.v4.12.6-rhodf   Succeeded
clusterserviceversion.operators.coreos.com/volsync-product.v0.7.4               VolSync                         0.7.4          volsync-product.v0.7.3               Succeeded

NAME                                            READY   STATUS    RESTARTS   AGE
pod/ramen-dr-cluster-operator-d9684948d-qhsgn   2/2     Running   0          9m19s
```



在  **Primary managed cluster**  和 **Secondary managed cluster** 上执行以下命令，查看ODF mirroring daemon，



```
[root@bastion-test4 odf-dr]# oc get cephblockpool ocs-storagecluster-cephblockpool -n openshift-storage -o jsonpath='{.status.mirroringStatus.summary}{"\n"}'
{"daemon_health":"OK","health":"OK","image_health":"OK","states":{}}
```





# 创建 DR 应用





![image-20230915110855982](./ODF-DR.assets/image-20230915110855982.png)



创建应用：

url： https://github.com/RamenDR/ocm-ramen-samples



![image-20230915111028726](./ODF-DR.assets/image-20230915111028726.png)



选择将应用部署在 test4 集群上



![image-20230915111427915](./ODF-DR.assets/image-20230915111427915.png)

结果如下所示：



![image-20230915111848986](./ODF-DR.assets/image-20230915111848986.png)



检查结果



```
[root@bastion-test4 odf-dr]# oc get pods,pvc -n busybox-sample
NAME                           READY   STATUS    RESTARTS   AGE
pod/busybox-645dbd9c68-rlkbv   1/1     Running   0          2m56s

NAME                                STATUS   VOLUME                                     CAPACITY   ACCESS MODES   STORAGECLASS                  AGE
persistentvolumeclaim/busybox-pvc   Bound    pvc-766c2190-ac50-429b-bb1b-e3fad517c50d   1Gi        RWO            ocs-storagecluster-ceph-rbd   2m56s
```



##    使用  DRpolicy



