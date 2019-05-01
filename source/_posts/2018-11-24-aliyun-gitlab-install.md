---
title: "阿里云 GitLab 折腾笔记"
issue: 36
date: 2018-11-24 23:09:44
categories: ["GitLab"]
tags: ["阿里云", "CentOS 7", "GitLab"]
---

想自己搭建一个 git 服务来玩一玩，正好有个阿里云，虽然配置很渣，但是也想着随便搞一搞。

于是从[官方教程](https://about.gitlab.com/install/)开始，遇到一些坑，查看一些资料，解决一些问题，有了下面的笔记。

<!-- more -->

选择对应的版本。我的阿里云装的是 `CentOS 7`,所以选择 `CentOS 7`的版本。

![](/images/aliyun-gitlab-install/aliyun-gitlab-install1.jpg)

> 通过下面的命令可以查看当前属于什么系统
>
```shell
lsb_release -a
```



## 安装和配置一些必要的依赖

### Step1

通过下面的命令，在系统防火墙中开启 HTTP 和 SSH 的访问。

```shell
sudo yum install -y curl policycoreutils-python openssh-server
sudo systemctl enable sshd
sudo systemctl start sshd
sudo firewall-cmd --permanent --add-service=http
sudo systemctl reload firewalld
```

在执行 

`sudo firewall-cmd --permanent --add-service=http`

时可能会遇到 `FirewallD is not running`的错误提示；

意思是：`防火墙服务没有运行`。这开启防火墙服务就行了：

```shell
systemctl start firewalld.service	
```

然后重新执行命令就会提示 `success`

![](/images/aliyun-gitlab-install/aliyun-gitlab-install2.jpg)



### Step 2

执行下面命令，安装并开启 `Postfix` 邮件通知服务

```shell
sudo yum install postfix
sudo systemctl enable postfix
sudo systemctl start postfix
```

这里遇到一个报错

![](/images/aliyun-gitlab-install/aliyun-gitlab-install3.jpg)

解决办法是修改 `/etc/postfix/main.cf`文件中的下面信息

```shell
inet_interfaces = all
inet_protocols = ipv4 // 或者 all
```

然后重启服务就好了：

```shell
sudo systemctl restart postfix
```



## 添加 GitLab 软件包的仓库，并安装

安装 GitLab

```shell
curl https://packages.gitlab.com/install/repositories/gitlab/gitlab-ee/script.rpm.sh | sudo bash
```

设置 GitLab 访问域名

```shell
sudo EXTERNAL_URL="http://gitlab.example.com" yum install -y gitlab-ee
```

注意：这里 `http://gitlab.example.com`替换成对应的**域名**或者**IP**

我这里设置成 IP 加 8888 端口，这需要在阿里云上配置安全组规则，出入方向都要配置对应端口。例如：

![](/images/aliyun-gitlab-install/aliyun-gitlab-install4.jpg)

然后设置防火墙：

```shell
# 开启 8888 端口
firewall-cmd --zone=public --add-port=8888/tcp --permanent
# 重启防火墙
systemctl restart firewalld
```

然后再执行下面的命令，等待安装完毕（安装过程可能比较久）

```shell
sudo EXTERNAL_URL="http://xx.xx.xx.xx:8888" yum install -y gitlab-ee
```

如果安装完之后要修改访问的域名或者 IP，则修改 `/etc/gitlab/gitlab.rb`文件中的 `external_url` 内容

然后重新配置服务

```
gitlab-ctl reconfigure
```

然后就可能用设置的域名（IP）访问了。



## 登录

第一次打开，会打开密码设置页面，让你设置密码。

设置密码之后，使用用户名 root 和设置的密码登录。

最后来个登录成功的图：

![](/images/aliyun-gitlab-install/aliyun-gitlab-install5.jpg)



## 遇到的问题

### 一些常用命令

```shell
//启动
sudo gitlab-ctl start

//停止
sudo gitlab-ctl stop

//重启
sudo gitlab-ctl restart

//查看状态
sudo gitlab-ctl status

//使更改配置生效
sudo gitlab-ctl reconfigure
```



### 开启阿里云 SWAP

刚安装结束，开启 GitLab 之后，阿里云就开始卡爆了，GitLab 也直接无法访问，或者是直接 502，白忙活的半天！内存爆炸了啊！这时候想到阿里云好像是没开启 SWAP 的。于是就有了下面的内容。

查看 swap 分区：

```shell
cat /proc/swaps
```

发现是空的，下面来开启 swap

详情参考：[云服务器 ECS Linux SWAP 配置概要说明](https://help.aliyun.com/knowledge_detail/42534.html)

1. 创建swap大小为bs(block_size)*count(number_of_block)=4G

   ```shell
   dd if=/dev/zero of=/mnt/swap bs=1M count=4096
   ```

2. 设置交换分区文件

   ```shell
   mkswap /mnt/swap
   ```

3. 立即启用交换分区文件

   ```shell
   swapon /mnt/swap
   ```

4. 权限设置

   提示：swapon: /mnt/swap：不安全的权限 0644，建议使用 0600，设置权限

   ```shell
   chmod 0600 /mnt/swap
   ```

   然后重新启用

5. 设置开机时自启用 SWAP 分区

   需要修改文件 /etc/fstab 中的 SWAP 行，在文件末位添加

   ```shell
   /mnt/swap swap swap defaults 0 0
   ```

6. 修改 swpapiness 参数

   ```shell
   cat /proc/sys/vm/swappiness
   ```

   通过上面命令看到 swappiness 值为 0，需要在物理内存使用完毕后才会使用 SWAP 分区

   ![](/images/aliyun-gitlab-install/aliyun-gitlab-install6.jpg)

    我们配置为空闲内存少于 10% 时才使用 SWAP 分区

   ```shell
   echo 10 >/proc/sys/vm/swappiness
   ```

   若需要永久修改此配置，在系统重启之后也生效的话，可以修改 /etc/sysctl.conf 文件，并修改以下内容:

   ```shell
   vm.swappiness=10
   ```

开启 SWAP 之后，GitLab 就能访问了！


## 总结

这篇笔记，主要是记录一下这次安装 GitLab 遇到的坑，以及对应的解决方案。


> 参考资料：
>
> [官方教程](https://about.gitlab.com/install/)
> [CentOS 初体验十四：阿里云安装Gitlab](https://blog.csdn.net/zhaoyanjun6/article/details/79144175)
> [云服务器 ECS Linux SWAP 配置概要说明](https://help.aliyun.com/knowledge_detail/42534.html)