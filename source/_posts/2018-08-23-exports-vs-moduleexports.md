---
title: Node.js 之 module.exports 和 exports
date: 2018-08-23 19:13:58
categories: "Node.js"
tags: [前端,Node]
issue: 17
---
![](https://ws1.sinaimg.cn/large/006tNbRwgy1fujuxtngyxj31kw11xu10.jpg)
## 前言
Node.js 模块系统是采用 CommonJS 模块规范的。每个文件视为一个独立的模块。使用 require 导入模块，使用 module.exports 和 exports 导出模块。
那么 module.exports 和 exports 的区别在哪里呢？

<!-- more -->

## module.exports
1. module.exports 就是 require() 的返回值
2. module.exports 是模块系统自动创建的，且初始化为空对象 {}

##  exports 快捷方式
1. exports 是为了方便快捷创建的变量，指向 module.exports 的引用

## 说明
可以看一下 [Node 文档](http://nodejs.cn/api/modules.html#modules_exports_shortcut) 中的一段解释
```js
function require(/* ... */) {
  const module = { exports: {} };
  ((module, exports) => {
    // 模块代码在这。在这个例子中，定义了一个函数。
    function someFunc() {}
    exports = someFunc;
    // 此时，exports 不再是一个 module.exports 的快捷方式，
    // 且这个模块依然导出一个空的默认对象。
    module.exports = someFunc;
    // 此时，该模块导出 someFunc，而不是默认对象。
  })(module, module.exports);
  return module.exports;
}
```

所以其实两者的关系是：
```js
exports = module.exports = {...}
```
module.exports 是一个对象，exports 是对 module.exports 的引用，即他们指向同一块内存。如图所示：
![](https://ws2.sinaimg.cn/large/006tNbRwgy1fujmsr1hdfj30jk0e8dgn.jpg)

所以如果对 exports （或者 module.exports） 的对象修改，就是对他们共同指向的内存的内容做修改，两者都会影响。
```js
// 这样是可以的
exports.obj = 1;
// or
module.exports.obj = 1;
```

但是如果直接将 exports (或者 module.exports) 指向一个值，则会使 exports (或者 module.exports) 指向新的内存块，等于断开了 exports 和 module.exports 的联系。下面的两种情况，导出的值要看 module.exports 的值
```js
// 直接赋值 exports 是无效的，导出的模块就不是 exports 的值了
exports = function(x) {console.log(x)};
// 直接赋值 module.exports 也会导致 exports 的值无法导出
exports.obj = 1;
module.exports = 2;
```
![](https://ws3.sinaimg.cn/large/006tNbRwgy1fujnekk29fj312k0diabx.jpg)

这时候，我们可以 exports = module.exports 让 exports 重新指向 module.exports

## 总结
对于 module.exports 和 exports 我们只需要记住三点就行了：

1. module.exports 是模块系统自动创建的，且初始化为空对象 {}
2. require() 返回的是 module.exports 的值
3. exports 指向 module.exports 的引用

在使用中，建议使用 module.exports 来导出模块，这样可以应对所有情况。

