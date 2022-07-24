

# setup env

```

sudo ln -s $(which python3) /usr/bin/python

# 查找execsnoop的路径，发现所有执行文件都在 /usr/share/bcc/tools/ 下，所以可以考虑将/usr/share/bcc/tools/ 添加到系统路径下
rpm -ql bcc-tools | grep execsnoop

export PATH=$PATH:/usr/share/bcc/tools/

# 执行命令 

/usr/share/bcc/tools/execsnoop
```

