---
title: "webpack4 升级记"
issue: 40
date: 2019-03-10 21:38:03
categories:
tags: ["webpack"]
---

![](https://ws3.sinaimg.cn/large/006tKfTcgy1g0y1fb94kzj30zk0g6410.jpg)

## 前言

号称 “**零配置**”、“**最高可提升98%的速度**” 的 webpack4 已经出来一段时间了，而且 webpack5 也已经在路上了。再不体验一下 webpack4 就老了！目前项目使用的还是 webpack3，打包速度确实是锻炼人的耐心，这次趁着有点时间，决心优化一下项目，尝试从 webpack 升级开始。期间断断续续也遇到不少问题，在这里对大致的过程做个记录。

> 犹记当年，也是我把 webpack 从 v1 升级到 v3 的

<!-- more -->

## 安装 webpack 以及相关配置

1. 先删除之前的 webpack、webpack-dev-server

```shell
npm uninstall webpack webpack-dev-server --save-dev
```

2. 安装最新版本的 webpack、webpack-cli (webpack4 把脚手架 webpack-cli 从 webpack 中抽离出来的，所以必须安装 webpack-cli)、webpack-dev-server

```
npm install webpack webpack-dev-server webpack-cli --save-dev
```

3. webpack4 已不支持 [extract-text-webpack-plugin](https://github.com/webpack-contrib/extract-text-webpack-plugin)，改用 [mini-css-extract-plugin](https://github.com/webpack-contrib/mini-css-extract-plugin)

```shell
npm uninstall --save-dev extract-text-webpack-plugin
npm install --save-dev mini-css-extract-plugin
```

4. 安装新版的 [html-webpack-plugin](https://github.com/jantimon/html-webpack-plugin)

```shell
npm uninstall --save-dev html-webpack-plugin
npm i --save-dev html-webpack-plugin
```

5. 还有其他的一些相关的包，在调试的过程中，排查出对应升级



## 遇到的问题

按 webpack4 的要求升级并配置好之后，就开始尝试在项目跑开发环境了。这个过程一波三折，升级花费的时间主要都在这里了。

### 路径问题
首先遇到的是巨坑，是 scss 里的路径问题。

路径处理使用 `resolve-url-loader` 来把路径处理成绝对路径，这个 `loader` 可以解决 sass 中，引用不同目录的 scss 文件，从而导致原来的相对 `url` 错误的问题。

升级这个 `loader` 后，scss 中图片字体路径一直 `can't resolve`，一开始以为是升级后配置不对，在这里卡了好久，一直看配置，改配置，查相关的 `loader`，无果！

最后决定还是从源码入手，使用 `vscode` 的调试功能，调试一下这个 `loader` 的处理情况。果然发现问题， `resolve-url-loader` v2 和 v3 的路径处理的方式改了！v2 会循环查找每一级的目录，而 v3 只会根据提供的路径生成对应的绝对路径来查找。

发现错的不是升级后的配置，而是以前代码里很多路径本身就写错了，比如 

```scss
// 然而事实上，当前目录下根本没有 img 目录。应该是 ../img/test.png
background-image: url(./img/test.png);
```

但是因为 `resolve-url-loader` 循环每一级查找的原因，还是能找到对应的图片。所以原来虽然写的自由奔放，但是也没有报错。（有些是因为 `copy` 其他地方的代码，但是没有 `copy` 对应的资源文件导致的）

如此巨坑，所以又陷入了修改大批错误路径的工作中。。。

### 性能问题
解决路径问题之后，势如破竹，大部分问题只要找到相关处理的 `loader` 或者 `plugin` 通过调试，都能找到原因。

webpack4 跑起来后，整体的速度已经是提升一大截了，单独打包主流程的时间从 `155s` 降到了 `70s` 左右，提升近 **55%**。

但是接着发现了一个神奇的问题，开发环境和打包速度竟然差不多，甚至更慢！！！

首先想到的是 `source-map` 的配置，严重拖慢速度。

但是修改不同的 `devtool`，发现变化并不大。问题不在这。

然后想到 `icon-font`。

于是看满屏密密麻麻的打包信息，发现字体文件不断重复的引入。发现是 sass 公共 `util` 模块里引用了字体的模块，然后之前一次修改，增加了每个 `scss` 自动引入 `util` 的 `loader` 。

果然，改正这个问题，只引入一次字体后，开发环境速度直接快了一倍。

### sass 公共模块的问题
上面的问题，其实和这个问题相关：就是 sass 公共模块的问题。

其实原因在于，`sass-loader` 对 `@import` 是不会去重的，重复 `import` 的 `scss` 会重复出现。[sass-loader](https://github.com/webpack-contrib/sass-loader)` issue [Duplicate Imports ](https://github.com/webpack-contrib/sass-loader/issues/145) 中有讨论这个问题，但是并没有很好的解决方案。

要解决这个问题，从几个方面入手：

1. 规范 sass 公共模块，需要在每个文件引入的公共变量、function 之类的，不要带有会生成 css 的代码。（可以借助 [sass-resources-loader](https://github.com/shakacode/sass-resources-loader) 自动每个文件引入需要的公共模块）。
2. 对于 `global.scss`, `reset.scss`, `common.scss` 这种生成 `css` 的公共模块，在 `js` 中 `import/require`。
3. 使用 [optimize-css-assets-webpack-plugin](https://github.com/NMFR/optimize-css-assets-webpack-plugin) 可以去掉重复的 `css`。



## 对比

### 某单个项目升级前后对比

| time     | development      | production         |
| -------- | ---------------- | ------------------ |
| webpack3 | 82.676s          | 183.235s           |
| webpack4 | 33.6s(提升59.3%) | 66.429s(提升63.7%) |

### 全部项目打包前后对比

| time     | production      |
| -------- | --------------- |
| webpack3 | 1070s           |
| webpack4 | 343s(提升67.9%) |



## 结论

这次升级虽然费了不少功夫，踩了不少坑，但也收获不少经验和一些新的思路。同时，一些问题，也暴露出团队项目上的一些问题。

升级 webpack4 后，速度大幅度提升，整个团队的开发效率可以说将近 **提升 70% * 团队** 吧。但是还可以继续深入优化，还有不少的提升空间。可以使用 [speed-measure-webpack-plugin](https://github.com/stephencookdev/speed-measure-webpack-plugin) 来检测webpack打包过程中各个部分所花费的时间，再根据分析来做优化。还可以考虑 `babel` 升级到 v7 和开发环境的 `node` 层升级优化。

告辞！