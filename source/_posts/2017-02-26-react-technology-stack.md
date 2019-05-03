---
title: React开发技术栈
date: 2017-02-26 20:26:12
categories: 
  - "前端"
  - "React"
tags: [React]
---

　　在之前的项目中，使用React进行开发，这里简单介绍一下搭建React开发环境和开发过程中所用到的技术和工具，从全局去浏览一下React全家桶，也算是一个总结和记录。

<!--more-->

### 项目解决方案
* 多页 + Ajax + 前端框架(React) + (模块化)依赖管理(webpack/ES2015) + 状态管理(Redux)

### 工具列表
* Node环境
* 构建工具webpack
* ES6语法
* ES6编译工具Babel
* 框架React
* 状态管理Redux
* Ajax请求库superagent

### 编码规范
* 使用Airbnb的React编码规范，实际使用中根据实际情况调整
[Airbnb React/JSX Style  Guide](https://github.com/hhking/javascript/tree/master/react)


### Node & npm
　　首先要安装Node.js，这是整个工程的一个运行环境。
　　Node中的path模块在项目的配置中比较常用，这里列举比较常用的方法。

  #### Node path模块
  ```
  <!-- 首先需要引入path -->
  var path = require('path');
  ```
  * path.join()

  path.join方法用于连接路径。该方法会正确使用当前系统的路径分隔符，Unix系统是”/“，Windows系统是”\“，可以解决不同平台的兼容问题。

  ```
  path.join(mydir, "src");
  ```

  * path.resolve()

  path.resolve() 将相对路径转为绝对路径

  它可以接受多个参数，依次表示所要进入的路径，直到将最后一个参数转为绝对路径。如果根据参数无法得到绝对路径，就以当前所在路径作为基准。除了根目录，该方法的返回值都不带尾部的斜杠。

  ```
  path.resolve('/foo/bar', './baz')
  // '/foo/bar/baz'Â

  path.resolve('/foo/bar', '/tmp/file/')
  // '/tmp/file'

  path.resolve('wwwroot', 'static_files/png/', '../gif/image.gif')
  // 如果当前目录是/home/myself/node，返回
  // /home/myself/node/wwwroot/static_files/gif/image.gif
  ```

  详细可以看[阮一峰讲的Path模块](https://javascript.ruanyifeng.com/nodejs/path.html)

  #### npm
  　　npm是Node的模块管理器，功能极其强大

  * 常用命令：
  ```
  <!-- 自动安装package.json里保存的模块 -->
  npm install
  <!-- 安装指定的模块 -->
  npm install --save-dev <packageName>
  ```

  * 配置文件： package.json
  保存了Node.js的配置，可以手动创建，也可以通过npm init命令来进行配置


### webpack
  　　webpack是前端资源加载/打包工具，目的就是把有依赖关系的各种文件打包成一系列的静态资源。
  ![imgage](/images/what-is-webpack.png)

  业界通用的方案是直接用npm scripts来定义项目内置脚本

  ```
  //example
  //--profile输出性能数据，可以看到每一步的耗时
  //--colors 输出结果带彩色，比如：会用红色显示耗时较长的步骤
  //--hot 模块热替换
  "start": "cross-env NODE_ENV=development webpack-dev-server --progress  --profile --colors --hot --content-base ../../../"

  npm run start
  ```

  ```
  <!-- 安装webpack -->
  npm install -g webpack
  <!-- webpack配套的web服务器webpack-dev-server -->
  npm install --save-dev webpack-dev-server
  ```


### React

　　React把用户界面抽象成一个组件，例如按钮组件Button、对话框组件Dialog、日期组件Calendar，一个完整的页面就是开发者通过组合这些组件，最终得到的功能丰富、可交互的页面。由于有了组件这层抽象，整个结构更加清晰，复用也更加容易。

![image](/images/component_example.png)

React具有以下特点
* 专注视图层
* Virtual DOM
* 函数式编程



### ECMAScript 6

　　ES6十大特性
* Default Parameters（默认参数） in ES6
* Template Literals （模板文本）in ES6
* Multi-line Strings （多行字符串）in ES6
* Destructuring Assignment （解构赋值）in ES6
* Enhanced Object Literals （增强的对象文本）in ES6
* Arrow Functions （箭头函数）in ES6
* Promises in ES6
* Block-Scoped Constructs Let and Const（块作用域构造Let and Const）
* Classes（类） in ES6
* Modules（模块） in ES6

　　使用ES6语法，可以使用新的语法的特性，减少大量冗余的代码，提高编码的效率，同时也能提高程序的健壮性。

可以通过下面这本书来学习ES6
[ECMAScript 6 入门](https://es6.ruanyifeng.com/):阮一峰的一本开源的 JavaScript 语言教程，全面介绍 ECMAScript 6 新引入的语法特性。


### ES6编译工具：Babel
　　怎么使用ES6？使用ES6编译工具Babel，将将ES6代码转为ES5代码，从而在现有环境执行。当然，也有一些方法特性在一些低级浏览器还不支持，我们可以加入Babel的polyfill来支持。
　　Babel的配置文件是.babelrc，用来设置转码规则和插件。

### Redux

　　Redux是Flux架构的的优化和扩展
在复杂应用中和React结合使用，管理React的数据状态，让React专注于视图层
但是对于简单的UI层，Redux就不是必要的，用了反而增加复杂性


### CSS Modules

* 样式局部化，解决命名冲突和全局污染问题
* class名的生成规则配置灵活
* 组件化，一个组件的JavaScript里就包含了组件所依赖的CSS

　　配合React，我们可以使用简化CSSModules的库[react-css-modules](https://github.com/gajus/react-css-modules)

### Ajax请求库
* [superagent](https://github.com/visionmedia/superagent)
Node.js里一个方便的请求代理模块，我们用它来实现我们的Ajax请求

* [reqwest](https://github.com/ded/reqwest)

* [axios](https://github.com/mzabriskie/axios)
支持Promise

* [fetch](https://developer.mozilla.org/zh-CN/docs/Web/API/Fetch_API/Using_Fetch)
需要配合[fetch polyfill](https://github.com/github/fetch)
缺少进度progress，中断abort等一些方法


### 其他

* 提升React性能的[Immutable](https://github.com/facebook/immutable-js/)库，以及配套的PureRender库(react-immutable-render-mixin)(https://github.com/jurassix/react-immutable-render-mixin)
* 动画库[React Motion](https://github.com/chenglou/react-motion)
