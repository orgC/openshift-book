

# 目标

scapy 是一个可以构造tcp包的工具，可以尝试使用该工具模拟网络异常包





# 安装



```
yum install -y python3 

pip3 install scapy
```







# Demo



```

# 目标 IP 和端口
target_ip = "192.168.3.104"
target_port = 29000
local_port = 12345

# 创建并发送 SYN 包，指定本地端口
syn = IP(dst=target_ip) / TCP(sport=local_port, dport=target_port, flags="S")
syn_ack = sr1(syn)

# 以后续的步骤继续通信，记得使用相同的本地端口
ack = IP(dst=target_ip) / TCP(sport=local_port, dport=target_port, flags="A", seq=syn_ack.ack, ack=syn_ack.seq + 1)
send(ack)

# 建立完握手后，发送一个payload为hello的数据包
payload = "hello"

push = IP(dst=target_ip) / TCP(dport=target_port, flags="PA", seq=syn_ack.ack, ack=syn_ack.seq + 1) / payload
send(push)


# 发送带有 "hello" 数据的数据包
hello = IP(dst=target_ip) / TCP(dport=target_port, flags="PA", seq=syn_ack.ack, ack=syn_ack.seq + 1) / "hello"
response = sr1(hello)

# 发送带有 "world" 数据的数据包
world = IP(dst=target_ip) / TCP(dport=target_port, flags="PA", seq=response.ack, ack=response.seq + len(response.payload)) / "world"
send(world)



# 发送一个payload 为 olleh 的异常包
payload = "hello"

push = IP(dst=target_ip) / TCP(dport=target_port, flags="PA", seq=syn_ack.ack, ack=syn_ack.seq + 1) / payload
send(push)

```

