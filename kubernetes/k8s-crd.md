



# 目标

1. 学习通过 CRD 对K8S 进行扩展



# kubebuilder



## golang env setup 

```

curl -LO https://go.dev/dl/go1.20.3.linux-amd64.tar.gz 

rm -rf /usr/local/go && tar -C /usr/local -xzf go1.20.3.linux-amd64.tar.gz

echo 'export PATH=$PATH:/usr/local/go/bin' >> ~/.bashrc
source ~/.bashrc

go version 

```



## install kubebuilder 

```

curl -L -o kubebuilder https://go.kubebuilder.io/dl/latest/$(go env GOOS)/$(go env GOARCH)
chmod +x kubebuilder && mv kubebuilder /usr/local/bin/


## add kubebuilder completion to bash 
echo 'source <(kubebuilder completion bash)' >> ~/.bashrc

```



