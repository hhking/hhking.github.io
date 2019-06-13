---
title: "Babel 7 升级实践"
subtitle: "Babel 7 Update Practice"
issue: 42
date: 2019-04-02 12:14:49
categories:
  - 前端
  - Babel
tags: ["Babel"]
---

## 缘起
最近在看项目的升级和优化，项目用的是 Babel 6，踩了一下升级到 Babel 7 的坑。

<!-- more -->

## @babel/preset-env
[@babel/preset-env](https://babeljs.io/docs/en/babel-preset-env) 根据指定的执行环境提供语法装换，也提供配置 polyfill。

> `Babel 7` 已经弃用年份 `preset`: `babel-preset-es2015, babel-preset-es2016, babel-preset-es2017, babel-preset-latest`. 直接使用一个 `env` 搞定。

所以我们需要指定执行环境 Browserslist， Browserslist 的配置有几种方式，并按下面的优先级使用：
1. `@babel/preset-env` 里的 `targets`
2. `package.json` 里的 `browserslist` 字段
3. `.browserslistrc` 配置文件

> [browserslist](https://github.com/browserslist/browserslist) 是用来给不同的前端工具（Autoprefixer, babel-preset-env）共享 `target browsers` 和 `Node.js versions` 配置的. 一般推荐将配置写在 `package.json` 里的 `browserslist` 字段。

例如我们配置 `.babelrc` 如下：
```js
// .babelrc
{
  "presets": [
    [
      "@babel/preset-env",
      {
        "targets": {
          "ie": 10
        }
      }
    ]
  ]
}
```

源文件：
```js
// index.js
const f = () => {};

new Promise();

class Test {}
```

编译后是：
```js
"use strict";

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var f = function f() {};

new Promise();

var Test = function Test() {
  _classCallCheck(this, Test);
};
```

Babel 转换了浏览器不支持的箭头函数和 `Class`，但是 `Promise` 并没有变化。这是因为 Babel 只转换不兼容的新语法，而对新的 API，如 Iterator、Generator、Set、Maps、Proxy、Reflect、Symbol、Promise、Object.assign() 等，是不会转换的。这时候就需要 polyfill 了。

polyfill 的使用在 Babel 7 有一些不同：
- `useBuiltIns` 提供 `false`, `entry`, `usage` 三种方式
- `@babel/runtime`, `@babel/plugin-transform-runtime` 把 `helpers` 和 polyfill 功能拆分了。默认只提供 `helpers`。

## useBuiltIns
### false
```js
"useBuiltIns": false,
```
此时不对 `polyfill` 做操作。如果引入 `@babel/polyfill`，则无视配置的浏览器兼容，引入所有的 `polyfill`。

### entry
```js
"useBuiltIns": "entry",
"corejs": 2,
```
根据配置的浏览器兼容，引入浏览器不兼容的 `polyfill`。需要在入口文件手动添加 `import '@babel/polyfill'`，会自动根据 `browserslist` 替换成浏览器不兼容的所有 `polyfill`。

这里需要指定 `core-js` 的版本, 如果 `"corejs": 3`, 则 `import '@babel/polyfill'` 需要改成 
```js
import 'core-js/stable';
import 'regenerator-runtime/runtime';
```

编译结果：
```js
"use strict";

require("core-js/modules/es6.array.copy-within");

// ... 此处省略一大堆的 polyfill

require("core-js/modules/web.immediate");

require("core-js/modules/web.dom.iterable");

require("regenerator-runtime/runtime");

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var f = function f() {};

new Promise();

var Test = function Test() {
  _classCallCheck(this, Test);
};
```

### usage
```js
"useBuiltIns": "usage",
"corejs": 2,
```
`usage` 会根据配置的浏览器兼容，以及你代码中用到的 API 来进行 `polyfill`，实现了按需添加。

编译结果：
```js
"use strict";

require("core-js/modules/es6.promise");

require("core-js/modules/es6.object.to-string");

function _classCallCheck(instance, Constructor) { if (!(instance instanceof Constructor)) { throw new TypeError("Cannot call a class as a function"); } }

var f = function f() {};

new Promise();

var Test = function Test() {
  _classCallCheck(this, Test);
};
```

看上面的编译结果，会发现还有个问题，`_classCallCheck` 辅助函数是直接内嵌的，如果多个地方使用 `Class`，那每个地方都会添加这个辅助函数，大量重复。
这时候就需要 `@babel/plugin-transform-runtime` 了。

## @babel/plugin-transform-runtime
[@babel/plugin-transform-runtime](https://babeljs.io/docs/en/babel-plugin-transform-runtime) 这个插件是用来复用辅助函数的。

配置 `.babelrc`
```js
{
  "presets": [
    [
      "@babel/preset-env",
      {
        "useBuiltIns": "usage",
        "corejs": 2,
        "targets": {
          "ie": 10
        }
      }
    ]
  ],
  "plugins": [
    ["@babel/plugin-transform-runtime"]
  ]
}
```
编译结果：
```js
"use strict";

var _interopRequireDefault = require("@babel/runtime/helpers/interopRequireDefault");

var _classCallCheck2 = _interopRequireDefault(require("@babel/runtime/helpers/classCallCheck"));

require("core-js/modules/es6.promise");

require("core-js/modules/es6.object.to-string");

var f = function f() {};

new Promise();

var Test = function Test() {
  (0, _classCallCheck2.default)(this, Test);
};
```
可以发现，helpers 是通过 `require` 引入的，这样就不会存在代码重复的问题了。

## 拾遗
`Babel 7` 废弃了 `stage-x`，如果需要用到一些特性，需要自己安装对应的 plugin，然后再配置中配置 plugin。

`stage-x` 原本是对应 ECMAScript 提案的不同阶段，每个阶段有不同的特性，但是提案一直在变，这些特性可能更进一步，也可能废弃。`state-x` 是否应该保持和不断更新的提案一致？怎么处理都无法适应变化，所以直接使用 `stage-x` 对后期的维护造成困惑和风险。

`Babel 7` 还有个配置文件查找的问题，升级后可能会出现 `.babelrc` 配置无效的情况，需要根据目录结构和规则调整。简单的说：
- Babel 7 增加了 `root` 目录的概念，默认是 cwd 目录
- Babel 分成项目级配置文件(如：`.babel.config.js`)和文件级配置文件(如：`.babelrc`)
- 项目级目录是默认是在 `root` 目录查找，可以配置 `root` 或者 `rootMode` 来更改查找方式；也可以配置 `configFile` 来指定文件或者关闭项目级配置
- 文件级配置文件 `.babelrc` 会根据 `babelrcRoots` 配置（默认值为 `root`）的目录查找，且只作用于当前编译目录的 `package.json`

> 更详细的可以直接看文档的解释说明 [Config Files](https://babeljs.io/docs/en/config-files#project-wide-configuration)

## 总结
Babel 7 的配置方案：
- @babel/preset-env + targets + useBuiltins: usage
- @babel/plugin-transform-runtime
- 引入必要的 plugin

这样就实现了按需引入 `polyfill`，看起来也是相当完美。

但是想想还是存在问题的，比如：Babel 编译通常会排除 node_modules，所以 `"useBuiltIns": "usage"` 存在风险，可能无法为依赖包添加必要的 `polyfill`。云谦在博客 [Polyfill 方案的过去、现在和未来](https://github.com/sorrycc/blog/issues/80) 也提到一些问题，还有一些想法和展望，感觉写得挺好的。

> 关于 Babel 编译通常会排除 node_modules 的做法，通用的约定是 node_modules 下的包在发布时打包成 es5。但是也难保证全部都遵守约定，这就存在一定的风险。但是如果 Babel 处理 node_modules，编译速度慢不说，Babel 6 编译已编译过的代码也是存在问题的，据说这个问题在 Babel 7 解决了，maybe! 告辞！👋
