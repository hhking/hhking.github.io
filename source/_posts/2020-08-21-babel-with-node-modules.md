---
title: 从 Babel7 编译 node_modules 报错说起
subtitle: Babel7 with node_modules
issue: -1
date: 2020-08-21 19:06:48
categories:
  - 前端
  - Babel
tags: ["Babel"]
---

> 好久没更新博客了🙄, 这篇可以结合 [Babel 7 升级实践](https://blog.hhking.cn/2019/04/02/babel-v7-update/) 一起看

## 缘起

- A：我这边有问题啊，怎么页面空白？
- B：我这里明明是好的！
- A：你自己来试
- B：怎么这么多奇奇怪怪的问题

这是发生在我和同事之间的对话。我跑过去看了一下控制台，页面直接爆炸💥了：

```
Uncaught TypeError: $ is not a function
```

定位到是 `core-js` 的某个文件提示这个错，怎么回事？

google 了一圈，再结合项目的配置，终于定位到问题：`babel` 编译 `node_modules`, `core-js` 自己 polyfill 自己，导致的报错。

## 原因分析

好长一段时间没有看 babel 的配置，又重新学习了一遍。

我之前的博客 [Babel 7 升级实践](https://blog.hhking.cn/2019/04/02/babel-v7-update/) 在最后面的**总结**中提到，Babel 7 解决了编译 `node_modules` 的问题, 所以按照我们之前学到的内容，项目的 babel 的配置可能会是这样的：

```
{
  "presets": [
    [
      "@babel/preset-env",
      {
        modules: false,
        useBuiltIns: 'usage',
        corejs: {
          version: 3,
          proposals: true,
        },
        targets: {
          chrome: 58,
          ie: 11,
        },
      },
    ]
  ]
}
```

但是我们项目里还有 `core-js` 和 `webpack`，所以可能就悲剧了：

```
Uncaught TypeError: $ is not a function
```

为什么呢？具体可以看这个 [issue 的解释](https://github.com/zloirock/core-js/issues/743#issuecomment-572096103) ：

我们使用 polyfill 的时候会注入 `require("core-js/...")`, 这时
1. 导入 `core-js`
2. `core-js` 依赖 `webpack/buildin`
3. `webpack/buildin` 被编译，polyfill 需要依赖 `core-js`
4. `core-js` 在 `1` 已经导入过，`module.exports` 初始化成了 `{}`，原本是期望导入的是个函数，也就出现错误。

所以在编译 `node_modules` 时，需要注意：
- 排除掉 `core-js`
- `webpack/buildin`
- 如果还用到了 `@babel/plugin-transform-runtime`，还需要排除 `@babel/runtime-corejs3`

也就是 babel 需要添加下面配置：

```
exclude : [
  /\bcore-js\b/,
  /\bwebpack\/buildin\b/,
  /@babel\/runtime-corejs3/
]
```

通过 chrome 的调试，也可以确定上面说的，最后 `$` 其实是一个空对象（也就是导入了空对象，不是期望的函数）

我们断点在报错的位置：
![1.png](https://i.loli.net/2020/08/21/ZUnMzubiDetrOox.png)

可以看到是导入 `/internals/export` 是个空对象。我们找到 `/internals/export` ，在顶部断点后刷新页面，会发现先执行了这个文件
![2.png](https://i.loli.net/2020/08/21/FptPDOJ192vhniz.png)

由此我们大致可以看出来过程：
1、require `/internals/export`
2、`/internals/export` 往后执行，又 require 了 `es.array.index-of`
3、`es.array.index-of` 这时候 require `/internals/export`
4、`/internals/export` 已经导入了，`module.exports` 初始化成了 `{}`，所以 `$` 赋值成了空对象，继续执行就报错了


问题来了？为什么 `$` 会变成，其实是 `commonjs` 循环 `import` 的问题。

## 循环导入

上面的问题，可以说是 `commonjs` 的特性，看下面的例子：

```
File A:
var b = require(`file B`)

File B:
var a = require(`file A`)
```

当使用 commonjs require 一个模块的时候，模块的 export 会初始化成空对象：

```
module.exports = {}
```

在执行这个模块里的后续代码时，会对 export 进行扩展或者重写，也就是我们平时导出的内容：
```
exports.namedExport = function() { /* ... */ }; // extends

module.exports = { namedExport: function() { /* ... */ } }; // overrides
```

但是我们上面的代码，情况是这样的：

 - require 模块A，A 的导出初始化成空对象
 - A 又去 require 模块 B
 - B 这时又 require A

而 A 在一开始已经 require 过，A 里的后续代码不会再执行，所以返回了一个空对象。如果 A 继续执行，就会导致死循环了。所以 a 的值也就是个空对象了。

## 最开始的问题

通过上面的内容，我们知道了，只要我们编译 `node_modules` 时候，排除一些不需要的文件就行了。

但是在我们的项目，其实是已经配置了：

```
// babel.config.js
ignore: [/\core-js/, /webpack\/buildin/]
```

所以在我自己的电脑上是没问题的。问题在哪？

我用的是 `mac`，同事的是 `windows`，看来是 `windows` 下出现的问题。

查了一下 babel 的文档，发现 `ignore` 的匹配模式有两种，我们这里用的是 `RegExp`：
> RegExp - A regular expression to match against the normalized filename. On POSIX the path RegExp will run against a /-separated path, and on Windows it will be on a \-separated path.

也就是说 mac 和 windows 的分隔符是没法自动处理的，需要区分！

解决办法也简单，可以使用 `string` 的模式，或者简单粗暴的直接添加对 windows 的匹配：
```
// babel.config.js
ignore: [/\/core-js/, /webpack\/buildin/, /\\core-js/, /webpack\\buildin/]
```

## 总结

在 babel 编译 node_modules 时，需要注意下面的配置：
- 看情况需要 exclude `core-js`、`webpack/buildin`、`@babel/runtime-corejs3`
- 如果是在 `babel.config.js` 配置匹配模式，需要注意是否有跨平台的问题，比如分隔符的兼容

最后需要吐槽一下：加了 `node_modules` 编译，初次编译慢了一倍！！！告辞！👋

THE END！


## 参考资料
- [circular imports with webpack returning empty object](https://stackoverflow.com/questions/30378226/circular-imports-with-webpack-returning-empty-object)
- [How to exclude core-js using useBuiltIns: “usage”](https://stackoverflow.com/questions/57361439/how-to-exclude-core-js-using-usebuiltins-usage)
- [Babel MatchPattern](https://babeljs.io/docs/en/options#matchpattern)
- [useBuiltins: 'usage' fails with babel-loader when not excluding node_modules](https://github.com/babel/babel/issues/7559)
- [Uncaught TypeError: isObject is not a function (with useBuiltIns: usage)](https://github.com/zloirock/core-js/issues/743)

