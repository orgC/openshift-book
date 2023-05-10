





master  节点

```
nmcli con mod ens192 ipv4.addresses 192.168.3.70/24
nmcli con mod ens192 ipv4.gateway 192.168.3.1
nmcli con mod ens192 ipv4.method manual
nmcli con mod ens192 ipv4.dns "192.168.3.99"
nmcli con up ens192
```



node1

```
nmcli con mod ens192 ipv4.addresses 192.168.3.71/24
nmcli con mod ens192 ipv4.gateway 192.168.3.1
nmcli con mod ens192 ipv4.method manual
nmcli con mod ens192 ipv4.dns "192.168.3.99"
nmcli con up ens192
```



node2

```
nmcli con mod ens192 ipv4.addresses 192.168.3.72/24
nmcli con mod ens192 ipv4.gateway 192.168.3.1
nmcli con mod ens192 ipv4.method manual
nmcli con mod ens192 ipv4.dns "192.168.3.99"
nmcli con up ens192
```

