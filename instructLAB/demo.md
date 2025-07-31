

# demo



## env

```
ssh instruct@instructlab.nhjlp.sandbox1535.opentlc.com
NDA1Mzcx
```



## Demo



```
python3 -m venv --upgrade-deps venv

source venv/bin/activate
pip3 install git+https://github.com/instructlab/instructlab.git@v0.19.3
ilab config init

ilab model download --repository instructlab/granite-7b-lab-GGUF --filename=granite-7b-lab-Q4_K_M.gguf 
ilab model download --repository instructlab/merlinite-7b-lab-GGUF --filename=merlinite-7b-lab-Q4_K_M.gguf

ilab model serve --model-path /home/instruct/.cache/instructlab/models/granite-7b-lab-Q4_K_M.gguf

# client 
ilab model chat -m /home/instruct/.cache/instructlab/models/granite-7b-lab-Q4_K_M.gguf

# question
What is the Instructlab project?

mkdir -p /home/instruct/.local/share/instructlab/taxonomy/knowledge/instructlab/overview 

cp -av ~/files/instructlab_knowledge/qna.yaml /home/instruct/.local/share/instructlab/taxonomy/knowledge/instructlab/overview

ilab taxonomy diff

ilab data generate --model /home/instruct/.cache/instructlab/models/merlinite-7b-lab-Q4_K_M.gguf --sdg-scale-factor 5 --gpus 1

less /home/instruct/.local/share/instructlab/datasets/knowledge_train_msgs_* 


ilab model train --pipeline simple --model-path instructlab/granite-7b-lab --local --device cuda


# option

ilab model serve --model-path /home/instruct/files/ggml-ilab-pretrained-Q4_K_M.gguf

ilab model chat --greedy-mode -m ~/files/ggml-ilab-pretrained-Q4_K_M.gguf

```



# 后续目标

1. 在CMB 环境部署 rhel-ai



todo

1.  使用 dvd 安装 python 和 pip

```
dnf install python3.11 python3.11-pip git gcc g++ -y 



```



1. 





# install





## local repo



```

mkdir -p /mnt/rhel9-iso

mount -o loop /path/to/rhel-9.iso /mnt/rhel9-iso

mv /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup/
vi /etc/yum.repos.d/rhel9-local.repo


[RHEL9-BaseOS]
name=RHEL 9 BaseOS Local Repository
baseurl=file:///mnt/rhel9-iso/BaseOS/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release

[RHEL9-AppStream]
name=RHEL 9 AppStream Local Repository
baseurl=file:///mnt/rhel9-iso/AppStream/
gpgcheck=1
enabled=1
gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-redhat-release



```





## local service



```
yum install -y nginx 


```





```

systemctl --user daemon-reload

systemctl --user start ilab-serve.service

systemctl --user status ilab-serve.service

journalctl --user-unit ilab-serve.service

sudo loginctl enable-linger

systemctl --user stop ilab-serve.service


```





```

pip3 install git+https://github.com/instructlab/instructlab.git@v0.21.2


```



# nvidia-demo



```

mkdir mydemo
python3 -m venv --upgrade-deps venv
source venv/bin/activate

# 查看所有可用版本
(venv) [instruct@instructlab mydemo]$ pip index versions instructlab
WARNING: pip index is currently an experimental command. It may be removed/changed in a future release without prior warning.
instructlab (0.22.1)
Available versions: 0.22.1, 0.22.0, 0.21.2, 0.21.1, 0.21.0, 0.20.1, 0.20.0, 0.19.5, 0.19.4, 0.19.3, 0.19.2, 0.19.1, 0.19.0, 0.18.4, 0.18.3, 0.18.2, 0.18.1, 0.18.0, 0.17.2, 0.17.1, 0.17.0, 0.16.1, 0.16.0, 0.15.1



安装指定版本的instructlab
pip install instructlab==0.22.1 

# 查看结果 
(venv) [instruct@instructlab mydemo]$ ilab --version
ilab, version 0.22.1


mistral-7b-instruct-v0.2.Q4_K_M.gguf

ilab model download --repository TheBloke/Mistral-7B-Instruct-v0.2-GGUF --filename=mistral-7b-instruct-v0.2.Q4_K_M.gguf --hf-token 



# 训练的时候，指定训练轮数  --num-epochs 
ilab model train --device cpu --pipeline simple  --num-epochs 1 

```

