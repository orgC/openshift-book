

# 执行 ceph 命令

ODF 有以下两种方式可以执行 ceph 命令

## 在当前环境中执行

```

[root@bastion-test1 ocp4]# oc rsh -n openshift-storage $(oc get pods -n openshift-storage -o name -l app=rook-ceph-operator)
sh-4.4$
sh-4.4$
sh-4.4$ export CEPH_ARGS='-c /var/lib/rook/openshift-storage/openshift-storage.config'
sh-4.4$ ceph -s
  cluster:
    id:     b10b0506-a579-447b-9eee-7ef5210243a4
    health: HEALTH_OK

  services:
    mon: 3 daemons, quorum a,b,d (age 10h)
    mgr: a(active, since 11h)
    mds: 1/1 daemons up, 1 hot standby
    osd: 3 osds: 3 up (since 10h), 3 in (since 11h)
    rgw: 1 daemon active (1 hosts, 1 zones)

  data:
    volumes: 1/1 healthy
    pools:   12 pools, 353 pgs
    objects: 386 objects, 37 KiB
    usage:   156 MiB used, 600 GiB / 600 GiB avail
    pgs:     353 active+clean

  io:
    client:   852 B/s rd, 1 op/s rd, 0 op/s wr

sh-4.4$
sh-4.4$
```



## 创建tool pod

```
oc patch OCSInitialization ocsinit -n openshift-storage --type json --patch  '[{ "op": "replace", "path": "/spec/enableCephTools", "value": true }]'
```





# rook-debug-log

```

rook-ceph-operator 启用和禁用 debug 日志

# 启用 debug 日志

…
data:
  # The logging level for the operator: INFO | DEBUG
  ROOK_LOG_LEVEL: DEBUG
  
  
# 禁用debug 日志
…
data:
  # The logging level for the operator: INFO | DEBUG
  ROOK_LOG_LEVEL: INFO
```

