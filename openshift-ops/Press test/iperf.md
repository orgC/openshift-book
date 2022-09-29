# 部署iperf

通过daemonset 部署 iperf

```
oc new-project iperf-test 

cat << EOF | oc apply -f -
apiVersion: apps/v1
kind: DaemonSet
metadata:
   name: iperf3
   labels:
      app: iperf3
spec:
   selector:
      matchLabels:
        app: iperf3
   template:
      metadata:
         labels:
            app: iperf3
      spec:
         containers:
         -  name: iperf3
            image: clearlinux/iperf:3
            command: ['/bin/sh', '-c', 'sleep 1d']
            ports:
            - containerPort: 5201
EOF

```



# 参数说明



## 部分服务端参数

-s 以服务器模式运行

-D 后台运行服务器模式

 

## 部分客户端参数



| 参数 | 说明                                                         |
| ---- | ------------------------------------------------------------ |
| -c   | 以客户端模式运行，连接到服务端                               |
| -t   | 传输时间，默认10秒                                           |
| -O   | 忽略前几秒                                                   |
| -u   | 使用UDP协议，默认使用TCP协议                                 |
| -P   | 设置多线程的数目，通过使用多线程，可以在一定程度上增加网络的吞吐量 |
| -n   | 指定要发送的数据量。使用-n参数后，-t参数失效，传输完指定大小的数据包后，自动结束 |



 

## 服务器端输出说明

Interval  表示时间间隔。

Transfer  表示时间间隔里面转输的数据量。

Bandwidth  是时间间隔里的传输速率。

 

## 客户端输出说明

Cwnd：TCP 使用此变量来限制 TCP 客户端在收到已发送数据的确认之前可以发送的数据量



# 测试结果

## TCP 测试



### server 端

```
sh-5.1$ iperf3 -s -f M
-----------------------------------------------------------
Server listening on 5201 (test #1)
-----------------------------------------------------------
Accepted connection from 10.130.2.3, port 40214
[  5] local 10.129.2.14 port 5201 connected to 10.130.2.3 port 40228
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-1.00   sec   832 MBytes   832 MBytes/sec
[  5]   1.00-2.00   sec   879 MBytes   879 MBytes/sec
[  5]   2.00-3.00   sec   887 MBytes   887 MBytes/sec
[  5]   3.00-4.00   sec   872 MBytes   872 MBytes/sec
[  5]   4.00-5.00   sec   878 MBytes   878 MBytes/sec
[  5]   5.00-6.00   sec   905 MBytes   905 MBytes/sec
[  5]   6.00-7.00   sec   933 MBytes   933 MBytes/sec
[  5]   7.00-8.00   sec   884 MBytes   883 MBytes/sec
[  5]   8.00-9.00   sec   913 MBytes   913 MBytes/sec
[  5]   9.00-10.00  sec   891 MBytes   891 MBytes/sec
[  5]  10.00-10.00  sec   254 KBytes  1041 MBytes/sec
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate
[  5]   0.00-10.00  sec  8.67 GBytes   887 MBytes/sec                  receiver

```





### client： 单线程测试

```
sh-5.1$ iperf3 -c 10.129.2.14 -f M
Connecting to host 10.129.2.14, port 5201
[  5] local 10.130.2.3 port 40228 connected to 10.129.2.14 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   834 MBytes   834 MBytes/sec  254    760 KBytes
[  5]   1.00-2.00   sec   879 MBytes   879 MBytes/sec    0    885 KBytes
[  5]   2.00-3.00   sec   887 MBytes   887 MBytes/sec    0    902 KBytes
[  5]   3.00-4.00   sec   872 MBytes   872 MBytes/sec    0   1008 KBytes
[  5]   4.00-5.00   sec   877 MBytes   878 MBytes/sec    0   1.01 MBytes
[  5]   5.00-6.00   sec   906 MBytes   906 MBytes/sec    0   1.03 MBytes
[  5]   6.00-7.00   sec   933 MBytes   933 MBytes/sec    0   1.04 MBytes
[  5]   7.00-8.00   sec   884 MBytes   884 MBytes/sec   46   1.05 MBytes
[  5]   8.00-9.00   sec   913 MBytes   913 MBytes/sec    0   1.07 MBytes
[  5]   9.00-10.00  sec   891 MBytes   891 MBytes/sec    0   1.09 MBytes
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  8.67 GBytes   888 MBytes/sec  300             sender
[  5]   0.00-10.00  sec  8.67 GBytes   887 MBytes/sec                  receiver

iperf Done.
```



### client： 多线程测试

```
sh-5.1$ iperf3 -c 10.129.4.9 -f M  -P 2
Connecting to host 10.129.4.9, port 5201
[  5] local 10.131.0.6 port 44512 connected to 10.129.4.9 port 5201
[  7] local 10.131.0.6 port 44516 connected to 10.129.4.9 port 5201
[ ID] Interval           Transfer     Bitrate         Retr  Cwnd
[  5]   0.00-1.00   sec   480 MBytes   480 MBytes/sec  554    603 KBytes
[  7]   0.00-1.00   sec   528 MBytes   528 MBytes/sec  404    709 KBytes
[SUM]   0.00-1.00   sec  1008 MBytes  1008 MBytes/sec  958
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   1.00-2.00   sec   568 MBytes   567 MBytes/sec   92    845 KBytes
[  7]   1.00-2.00   sec   498 MBytes   498 MBytes/sec    0    855 KBytes
[SUM]   1.00-2.00   sec  1.04 GBytes  1065 MBytes/sec   92
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   2.00-3.00   sec   454 MBytes   454 MBytes/sec  139    807 KBytes
[  7]   2.00-3.00   sec   417 MBytes   417 MBytes/sec  105    804 KBytes
[SUM]   2.00-3.00   sec   871 MBytes   871 MBytes/sec  244
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   3.00-4.00   sec   521 MBytes   521 MBytes/sec   46    927 KBytes
[  7]   3.00-4.00   sec   452 MBytes   452 MBytes/sec    0    887 KBytes
[SUM]   3.00-4.00   sec   972 MBytes   972 MBytes/sec   46
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   4.00-5.00   sec   503 MBytes   503 MBytes/sec   96    879 KBytes
[  7]   4.00-5.00   sec   405 MBytes   405 MBytes/sec    4    900 KBytes
[SUM]   4.00-5.00   sec   908 MBytes   908 MBytes/sec  100
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   5.00-6.00   sec   536 MBytes   536 MBytes/sec  142    949 KBytes
[  7]   5.00-6.00   sec   479 MBytes   479 MBytes/sec   74    897 KBytes
[SUM]   5.00-6.00   sec  1014 MBytes  1014 MBytes/sec  216
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   6.00-7.00   sec   386 MBytes   386 MBytes/sec  235    826 KBytes
[  7]   6.00-7.00   sec   382 MBytes   382 MBytes/sec   46    986 KBytes
[SUM]   6.00-7.00   sec   768 MBytes   768 MBytes/sec  281
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   7.00-8.00   sec   586 MBytes   586 MBytes/sec   14    844 KBytes
[  7]   7.00-8.00   sec   493 MBytes   493 MBytes/sec  135    827 KBytes
[SUM]   7.00-8.00   sec  1.05 GBytes  1079 MBytes/sec  149
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   8.00-9.00   sec   631 MBytes   631 MBytes/sec   34    666 KBytes
[  7]   8.00-9.00   sec   513 MBytes   513 MBytes/sec   18    629 KBytes
[SUM]   8.00-9.00   sec  1.12 GBytes  1144 MBytes/sec   52
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   9.00-10.00  sec   579 MBytes   579 MBytes/sec    0    897 KBytes
[  7]   9.00-10.00  sec   483 MBytes   483 MBytes/sec    0    825 KBytes
[SUM]   9.00-10.00  sec  1.04 GBytes  1061 MBytes/sec    0
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Retr
[  5]   0.00-10.00  sec  5.12 GBytes   524 MBytes/sec  1352             sender
[  5]   0.00-10.00  sec  5.12 GBytes   524 MBytes/sec                  receiver
[  7]   0.00-10.00  sec  4.54 GBytes   465 MBytes/sec  786             sender
[  7]   0.00-10.00  sec  4.54 GBytes   465 MBytes/sec                  receiver
[SUM]   0.00-10.00  sec  9.66 GBytes   989 MBytes/sec  2138             sender
[SUM]   0.00-10.00  sec  9.66 GBytes   989 MBytes/sec                  receiver

iperf Done.
```





## UDP 测试



### server 端

```
Accepted connection from 10.130.2.3, port 52402
[  5] local 10.129.2.14 port 5201 connected to 10.130.2.3 port 52246
[ ID] Interval           Transfer     Bitrate         Jitter    Lost/Total Datagrams
[  5]   0.00-1.00   sec   124 MBytes   124 MBytes/sec  0.008 ms  0/92868 (0%)
[  5]   1.00-2.00   sec   207 MBytes   207 MBytes/sec  0.008 ms  9/155583 (0.0058%)
[  5]   2.00-3.00   sec   190 MBytes   190 MBytes/sec  0.027 ms  4444/147165 (3%)
[  5]   3.00-4.00   sec   189 MBytes   189 MBytes/sec  0.020 ms  3093/145000 (2.1%)
[  5]   4.00-5.00   sec   186 MBytes   186 MBytes/sec  0.018 ms  462/140274 (0.33%)
[  5]   5.00-6.00   sec   190 MBytes   190 MBytes/sec  0.005 ms  142/143010 (0.099%)
[  5]   6.00-7.00   sec   186 MBytes   186 MBytes/sec  0.004 ms  1381/140873 (0.98%)
[  5]   7.00-8.00   sec   191 MBytes   191 MBytes/sec  0.005 ms  14/143487 (0.0098%)
[  5]   8.00-9.00   sec   201 MBytes   201 MBytes/sec  0.004 ms  577/151082 (0.38%)
[  5]   9.00-10.00  sec   202 MBytes   202 MBytes/sec  0.017 ms  101/151307 (0.067%)
[  5]  10.00-10.00  sec   141 KBytes   247 MBytes/sec  0.005 ms  0/103 (0%)
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Jitter    Lost/Total Datagrams
[  5]   0.00-10.00  sec  1.82 GBytes   187 MBytes/sec  0.005 ms  10223/1410752 (0.72%)  receiver

```





### client : 单线程测试



```
sh-5.1$ iperf3 -c 10.129.2.14 -f M  -u -b 0
Connecting to host 10.129.2.14, port 5201
[  5] local 10.130.2.3 port 52246 connected to 10.129.2.14 port 5201
[ ID] Interval           Transfer     Bitrate         Total Datagrams
[  5]   0.00-1.00   sec   124 MBytes   124 MBytes/sec  92920
[  5]   1.00-2.00   sec   207 MBytes   207 MBytes/sec  155610
[  5]   2.00-3.00   sec   196 MBytes   196 MBytes/sec  147150
[  5]   3.00-4.00   sec   193 MBytes   193 MBytes/sec  145030
[  5]   4.00-5.00   sec   187 MBytes   187 MBytes/sec  140200
[  5]   5.00-6.00   sec   191 MBytes   191 MBytes/sec  143080
[  5]   6.00-7.00   sec   188 MBytes   188 MBytes/sec  140860
[  5]   7.00-8.00   sec   191 MBytes   191 MBytes/sec  143480
[  5]   8.00-9.00   sec   201 MBytes   201 MBytes/sec  151080
[  5]   9.00-10.00  sec   202 MBytes   202 MBytes/sec  151380
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Jitter    Lost/Total Datagrams
[  5]   0.00-10.00  sec  1.84 GBytes   188 MBytes/sec  0.000 ms  0/1410790 (0%)  sender
[  5]   0.00-10.00  sec  1.82 GBytes   187 MBytes/sec  0.005 ms  10223/1410752 (0.72%)  receiver

iperf Done.

```



### client： 多线程测试

```
sh-5.1$ iperf3 -c 10.129.4.9 -f M  -u -b 0 -P 3
Connecting to host 10.129.4.9, port 5201
[  5] local 10.131.0.6 port 49848 connected to 10.129.4.9 port 5201
[  7] local 10.131.0.6 port 43657 connected to 10.129.4.9 port 5201
[  9] local 10.131.0.6 port 40541 connected to 10.129.4.9 port 5201
[ ID] Interval           Transfer     Bitrate         Total Datagrams
[  5]   0.00-1.00   sec  40.9 MBytes  40.9 MBytes/sec  30660
[  7]   0.00-1.00   sec  42.1 MBytes  42.1 MBytes/sec  31560
[  9]   0.00-1.00   sec  40.9 MBytes  40.9 MBytes/sec  30660
[SUM]   0.00-1.00   sec   124 MBytes   124 MBytes/sec  92880
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   1.00-2.00   sec  63.6 MBytes  63.6 MBytes/sec  47700
[  7]   1.00-2.00   sec  63.6 MBytes  63.6 MBytes/sec  47710
[  9]   1.00-2.00   sec  63.6 MBytes  63.6 MBytes/sec  47700
[SUM]   1.00-2.00   sec   191 MBytes   191 MBytes/sec  143110
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   2.00-3.00   sec  67.2 MBytes  67.2 MBytes/sec  50370
[  7]   2.00-3.00   sec  67.0 MBytes  67.0 MBytes/sec  50290
[  9]   2.00-3.00   sec  67.2 MBytes  67.2 MBytes/sec  50370
[SUM]   2.00-3.00   sec   201 MBytes   201 MBytes/sec  151030
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   3.00-4.00   sec  66.3 MBytes  66.3 MBytes/sec  49700
[  7]   3.00-4.00   sec  66.3 MBytes  66.3 MBytes/sec  49750
[  9]   3.00-4.00   sec  66.3 MBytes  66.3 MBytes/sec  49700
[SUM]   3.00-4.00   sec   199 MBytes   199 MBytes/sec  149150
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   4.00-5.00   sec  68.0 MBytes  68.0 MBytes/sec  50980
[  7]   4.00-5.00   sec  67.9 MBytes  67.9 MBytes/sec  50930
[  9]   4.00-5.00   sec  68.0 MBytes  68.0 MBytes/sec  50980
[SUM]   4.00-5.00   sec   204 MBytes   204 MBytes/sec  152890
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   5.00-6.00   sec  62.7 MBytes  62.7 MBytes/sec  47040
[  7]   5.00-6.00   sec  62.7 MBytes  62.7 MBytes/sec  47060
[  9]   5.00-6.00   sec  62.7 MBytes  62.7 MBytes/sec  47040
[SUM]   5.00-6.00   sec   188 MBytes   188 MBytes/sec  141140
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   6.00-7.00   sec  63.0 MBytes  63.0 MBytes/sec  47270
[  7]   6.00-7.00   sec  63.2 MBytes  63.2 MBytes/sec  47380
[  9]   6.00-7.00   sec  63.0 MBytes  63.0 MBytes/sec  47270
[SUM]   6.00-7.00   sec   189 MBytes   189 MBytes/sec  141920
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   7.00-8.00   sec  64.2 MBytes  64.2 MBytes/sec  48160
[  7]   7.00-8.00   sec  64.1 MBytes  64.1 MBytes/sec  48090
[  9]   7.00-8.00   sec  64.2 MBytes  64.2 MBytes/sec  48160
[SUM]   7.00-8.00   sec   193 MBytes   193 MBytes/sec  144410
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   8.00-9.00   sec  62.1 MBytes  62.1 MBytes/sec  46600
[  7]   8.00-9.00   sec  62.1 MBytes  62.1 MBytes/sec  46580
[  9]   8.00-9.00   sec  62.1 MBytes  62.1 MBytes/sec  46590
[SUM]   8.00-9.00   sec   186 MBytes   186 MBytes/sec  139770
- - - - - - - - - - - - - - - - - - - - - - - - -
[  5]   9.00-10.00  sec  62.3 MBytes  62.3 MBytes/sec  46750
[  7]   9.00-10.00  sec  62.1 MBytes  62.1 MBytes/sec  46610
[  9]   9.00-10.00  sec  62.3 MBytes  62.3 MBytes/sec  46750
[SUM]   9.00-10.00  sec   187 MBytes   187 MBytes/sec  140110
- - - - - - - - - - - - - - - - - - - - - - - - -
[ ID] Interval           Transfer     Bitrate         Jitter    Lost/Total Datagrams
[  5]   0.00-10.00  sec   620 MBytes  62.0 MBytes/sec  0.000 ms  0/465230 (0%)  sender
[  5]   0.00-10.00  sec   618 MBytes  61.8 MBytes/sec  0.036 ms  1386/465217 (0.3%)  receiver
[  7]   0.00-10.00  sec   621 MBytes  62.1 MBytes/sec  0.000 ms  0/465960 (0%)  sender
[  7]   0.00-10.00  sec   619 MBytes  61.9 MBytes/sec  0.037 ms  1379/465947 (0.3%)  receiver
[  9]   0.00-10.00  sec   620 MBytes  62.0 MBytes/sec  0.000 ms  0/465220 (0%)  sender
[  9]   0.00-10.00  sec   618 MBytes  61.8 MBytes/sec  0.035 ms  1393/465207 (0.3%)  receiver
[SUM]   0.00-10.00  sec  1.82 GBytes   186 MBytes/sec  0.000 ms  0/1396410 (0%)  sender
[SUM]   0.00-10.00  sec  1.81 GBytes   186 MBytes/sec  0.036 ms  4158/1396371 (0.3%)  receiver

iperf Done.
```

