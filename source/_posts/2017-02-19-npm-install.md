---
title: npm install慢或者无响应解决方案
date: 2017-02-19 16:41:34
categories: "关于前端"
tags: [Node, npm]
---

npm默认是国外的源：http://registry.npmjs.org，
所以在国内会遇到npm install安装包的时候速度很慢，甚至无响应，
所以我们需要把npm切换成国内镜像源，为包的安装加速。

<!--more-->

>这里参考网上的一些解决方案，记录一下自己用的方法

### npm切换到淘宝npm镜像方法


#### 临时切换方案
-   通过命令行指定

        npm --registry https://registry.npm.taobao.org info underscore
    （如果上面配置正确这个命令会有字符串response，下次使用时需要重新设置）


#### 永久切换
    有下面两种方法，下次使用时不需要重新设置
-   通过config命令

        npm config set registry https://registry.npm.taobao.org
        npm info underscore

    （如果上面配置正确这个命令会有字符串response）


-   编辑 ~/.npmrc 加入下面内容

        registry = https://registry.npm.taobao.org


### 使用nrm切换

nrm是一个npm源管理器，可以让我们快速的切换不同的npm源

#### nrm安装

    npm install -g nrm

#### 列出所有源
```
  nrm ls

  npm ---- https://registry.npmjs.org/
  cnpm --- http://r.cnpmjs.org/
* taobao - https://registry.npm.taobao.org/
  nj ----- https://registry.nodejitsu.com/
  rednpm - http://registry.mirror.cqupt.edu.cn/
  npmMirror  https://skimdb.npmjs.com/registry/
  edunpm - http://registry.enpmjs.org/
```

#### 切换源
```
nrm use npm

   Registry has been set to: https://registry.npmjs.org/
```

#### 使用命令
```
Usage: nrm [options] [command]

  Commands:

    ls                           List all the registries
    use                Change registry to registry
    add   [home]  Add one custom registry
    del                Delete one custom registry
    home  [browser]    Open the homepage of registry with optional browser
    test [registry]              Show the response time for one or all registries
    help                         Print this help

  Options:

    -h, --help     output usage information
    -V, --version  output the version number
```

>   注:切换到其他npm之后，publish会无效，npm publish时要记得切回去

### 参考
>https://npm.taobao.org/
>https://segmentfault.com/a/1190000002642514
>https://github.com/Pana/nrm
>http://www.uedbox.com/npm-install-slow-solution/ （三种解决方案）
