



# 目标

markdown 学习笔记





# markdown 流程图



## 饼状图



```mermaid
pie
        title 今天晚上吃什么？
        "火锅" : 8
        "外卖" : 60
        "自己煮" : 8
        "海底捞" : 9
        "海鲜" : 5
        "烧烤" : 5
        "不吃" : 5

```







## other



```mermaid
flowchart LR
A1[矩形] o--o B1(圆角矩形) <--> C1{菱形} x--x D1((圆形))
A2[矩形] o-.-o B2(圆角矩形) <-.-> C2{菱形} x-.-x D2((圆形))
A3[矩形] o==o B3(圆角矩形) <==> C3{菱形} x==x D3((圆形))
```





## demo





```mermaid
graph RL

        User((用户))--1.用户登录-->Login(登录)
        Login --2.查询-->SERVER[服务器]
 subgraph 查询数据库
        SERVER--3.查询数据-->DB[(数据库)]
        DB--4.返回结果-->SERVER
 end
        SERVER--5.校验数据-->Condition{判断}
        Condition -->|校验成功| OK[登录成功]
        Condition -->|校验失败| ERR[登录失败]
        OK-->SYS[进入系统]

        ERR -->|返回登录页面,重新登录| Login
```





# Reference



https://rstyro.github.io/blog/2021/06/28/Markdown%E6%B5%81%E7%A8%8B%E5%9B%BE%E8%AF%AD%E6%B3%95%E7%A4%BA%E4%BE%8B/



https://snowdreams1006.github.io/write/mermaid-flow-chart.html





