

# prepare



## Adding vCenter root CA certificates to your system trust





![image-20230914142154341](./vmware-ipi.assets/image-20230914142154341.png)



```
unzip download.zip 

sudo cp certs/lin/* /etc/pki/ca-trust/source/anchors

sudo update-ca-trust extract
```







# install







