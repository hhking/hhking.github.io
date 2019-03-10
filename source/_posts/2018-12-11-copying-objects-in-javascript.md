---
title: "[译]JavaScript 如何复制对象"
issue: 39
date: 2018-12-11 19:14:13
categories: ["翻译"]
tags: ["复制对象", "浅复制", "深复制"]
---

> 原文: [COPYING OBJECTS IN JAVASCRIPT](https://smalldata.tech/blog/2018/11/01/copying-objects-in-javascript)
> 作者: Victor Parmar

这篇文章，我们将介绍在 JavaScript 中复制对象的各种方法。其中包括了浅复制和深复制。

<!-- more -->

开始之前，有必要说一些基础概念：JavaScript 中的对象，是对内存中存储位置的引用。这些引用是可变的，即：引用可以被重新赋值。因此，简单的复制引用，结果只会是两个引用同时指向内存中的同一个位置：

```js
var foo = {
    a : "abc"
}
console.log(foo.a); // abc

var bar = foo;
console.log(bar.a); // abc

foo.a = "yo foo";
console.log(foo.a); // yo foo
console.log(bar.a); // yo foo

bar.a = "whatup bar?";
console.log(foo.a); // whatup bar?
console.log(bar.a); // whatup bar? 
```

上面的例子可以看到，`foo` 和 `bar` 任意一个对象发生变化，都会反映到另一个对象上。所以，根据你的使用场景，在 JavaScript 中复制对象需要小心。

## SHALLOW COPY 浅复制

如果你的对象的属性都是值类型，你可以使用展开语法或者 `Object.assign(...)`

```js
var obj = { foo: "foo", bar: "bar" };

var copy = { ...obj }; // Object { foo: "foo", bar: "bar" }
```

```js
var obj = { foo: "foo", bar: "bar" };

var copy = Object.assign({}, obj); // Object { foo: "foo", bar: "bar" }
```

注意：上面两种方法，都可以用来从多个源对象复制属性值到目标对象：

```js
var obj1 = { foo: "foo" };
var obj2 = { bar: "bar" };

var copySpread = { ...obj1, ...obj2 }; // Object { foo: "foo", bar: "bar" }
var copyAssign = Object.assign({}, obj1, obj2); // Object { foo: "foo", bar: "bar" }
```

上述方法存在的问题是，当对象的属性本身是对象时，这个属性只会复制引用，也就是说，这和第一个例子中的 `var bar = foo` 是一样的：

```js
var foo = { a: 0 , b: { c: 0 } };
var copy = { ...foo };

copy.a = 1;
copy.b.c = 2;

console.dir(foo); // { a: 0, b: { c: 2 } }
console.dir(copy); // { a: 1, b: { c: 2 } }
```

## DEEP COPY 深复制（带警告）

深复制对象，一个可能可行的方法是，把对象序列化成字符串，然后再反序列化回来：

```js
var obj = { a: 0, b: { c: 0 } };
var copy = JSON.parse(JSON.stringify(obj));
```

可惜的是，这个方法只适用于：源对象包含的是可序列化的类型值，并且没有循环引用。一个不能序列化的类型值例子是 `Date` 对象 - 即使它打印成 ISO 格式字符串，`JSON.parse` 只会把它解释成字符串而不是 `Date` 对象。


## DEEP COPY 深复制（带少量的警告）

对更复杂的情况，可以使用新的 HTML5 克隆算法 ["structured clone"](https://developer.mozilla.org/en-US/docs/Web/API/Web_Workers_API/Structured_clone_algorithm)。可惜的是，在写本文的时候，这个方法还是限制于针对某些内置类型，但是它比 `JSON.parse` 支持更多的类型：Date, RegExp, Map, Set, Blob, FileList, ImageData, 稀疏数组和类数组。它还保留了克隆数据的引用，从而支持循环和递归结构，而上面提到的序列化方法不支持这点。

目前，没有直接调用结构化克隆算法的方法，但是一些较新的浏览器特性有使用这个算法。因此，通过一些变通的方法可以用来实现对象的深复制。

`通过 MessageChannels`: 这个思路是通过利用通信功能使用的序列化算法来实现。因为这个功能是基于事件的，所以生成克隆也是异步操作。

```js
class StructuredCloner {
  constructor() {
    this.pendingClones_ = new Map();
    this.nextKey_ = 0;

    const channel = new MessageChannel();
    this.inPort_ = channel.port1;
    this.outPort_ = channel.port2;

    this.outPort_.onmessage = ({data: {key, value}}) => {
      const resolve = this.pendingClones_.get(key);
      resolve(value);
      this.pendingClones_.delete(key);
    };
    this.outPort_.start();
  }

  cloneAsync(value) {
    return new Promise(resolve => {
      const key = this.nextKey_++;
      this.pendingClones_.set(key, resolve);
      this.inPort_.postMessage({key, value});
    });
  }
}

const structuredCloneAsync = window.structuredCloneAsync =
    StructuredCloner.prototype.cloneAsync.bind(new StructuredCloner);


const main = async () => {
  const original = { date: new Date(), number: Math.random() };
  original.self = original;

  const clone = await structuredCloneAsync(original);

  // different objects:
  console.assert(original !== clone);
  console.assert(original.date !== clone.date);

  // cyclical:
  console.assert(original.self === original);
  console.assert(clone.self === clone);

  // equivalent values:
  console.assert(original.number === clone.number);
  console.assert(Number(original.date) === Number(clone.date));

  console.log("Assertions complete.");
};

main();
```

`通过 history API`: `history.pushState()` 和 `history.replaceState()` 都会对第一个参数创建结构化克隆。注意，这个方法是同步的，操作浏览器的 history 并不是个很快的操作，所以频繁调用这个方法会导致浏览器无响应。

```js
const structuredClone = obj => {
  const oldState = history.state;
  history.replaceState(obj, null);
  const clonedObj = history.state;
  history.replaceState(oldState, null);
  return clonedObj;
};
```

`通过 notification API`: 创建新的通知时，构造函数会创建其中关联的 data 的结构化克隆。注意，这个也会尝试将通知展现给用户，但是这个默默的失败，除非应用请求过显示通知的权限。在已授予权限的场景下，通知马上被关闭。

```js
const structuredClone = obj => {
  const n = new Notification("", {data: obj, silent: true});
  n.onshow = n.close.bind(n);
  return n.data;
};
```

## NODE.JS 中深复制

从 version 8.0.0 开始，Node.js 提供 [serialization api](https://nodejs.org/api/v8.html#v8_serialization_api)，它兼容结构化克隆。注意，写这篇文章是，这个 API 属于实验性的：

```js
const v8 = require('v8');
const buf = v8.serialize({a: 'foo', b: new Date()});
const cloned = v8.deserialize(buf);
cloned.b.getMonth();
```

对于 8.0.0 以下版本，或者是需要更稳定的实现，一个是使用 lodash 的 `cloneDeep` 方法，这也是基于结构化克隆算法的。

## 结论

总结一下，JavaScript 中最好的复制对象算法，很大程度上取决于环境和你要复制的对象的类型。虽然 lodash 是通用深复制方法中最安全的选择，但是如果你自己实现，可以得到更高效的方案。下面是个简单的深复制例子，支持日期（`Date`）：

```js
function deepClone(obj) {
  var copy;

  // Handle the 3 simple types, and null or undefined
  if (null == obj || "object" != typeof obj) return obj;

  // Handle Date
  if (obj instanceof Date) {
    copy = new Date();
    copy.setTime(obj.getTime());
    return copy;
  }

  // Handle Array
  if (obj instanceof Array) {
    copy = [];
    for (var i = 0, len = obj.length; i < len; i++) {
        copy[i] = deepClone(obj[i]);
    }
    return copy;
  }

  // Handle Function
  if (obj instanceof Function) {
    copy = function() {
      return obj.apply(this, arguments);
    }
    return copy;
  }

  // Handle Object
  if (obj instanceof Object) {
      copy = {};
      for (var attr in obj) {
          if (obj.hasOwnProperty(attr)) copy[attr] = deepClone(obj[attr]);
      }
      return copy;
  }

  throw new Error("Unable to copy obj as type isn't supported " + obj.constructor.name);
}
```

个人而言，我希望可以在任何地方使用结构化克隆，这样这个问题（对象复制）就可以解决了：开心的克隆:)
