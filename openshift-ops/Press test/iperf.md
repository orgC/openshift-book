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

-c  以客户端模式运行，连接到服务端

-t   传输时间，默认10秒

-O  忽略前几秒

-u  使用UDP协议，默认使用TCP协议

 

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





### client 端

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





### client 端



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



