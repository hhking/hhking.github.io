---
title: "[译] 5 分钟学习一些优雅的 JavaScript 技巧"
issue: 30
date: 2018-09-21 17:49:44
categories: [翻译]
tags: ["前端", "JavaScript", "经验分享"]
---

> 原文：[Learn these neat JavaScript tricks in less than 5 minutes](https://medium.freecodecamp.org/9-neat-javascript-tricks-e2742f2735c3)
作者：Alcides Queiroz

![](https://i.loli.net/2019/05/26/5ce9e86f1eff798032.png)
**5 分钟学习一些优雅的 JavaScript 技巧 —— 专业的省时技巧**

<!-- more -->

## 1. 清空或截取数组
一个简单的清空或者截取数组的方法，就是修改它的 `length` 属性：

```js
const arr = [11, 22, 33, 44, 55, 66];
// 截取
arr.length = 3;
console.log(arr); //=> [11, 22, 33]
// 清空
arr.length = 0;
console.log(arr); //=> []
console.log(arr[2]); //=> undefined
```

## 2.用对象解构来模拟参数命名
当你要给函数传入带有一系列配置的参数时，你很可能会使用配置对象的方法，例如：

```js
doSomething({ foo: 'Hello', bar: 'Hey!', baz: 42 });
function doSomething(config) {
  const foo = config.foo !== undefined ? config.foo : 'Hi';
  const bar = config.bar !== undefined ? config.bar : 'Yo!';
  const baz = config.baz !== undefined ? config.baz : 13;
  // ...
}
```

在 JavaScript 中模拟命名参数，是一个陈旧但是很有效的方式。这样函数调用看起来舒服多了。另一方面，配置对象的控制逻辑也不需要这么冗长，使用 ES2015 的对象解构，可以避免这个问题：

```js
function doSomething({ foo = 'Hi', bar = 'Yo!', baz = 13 }) {
  // ...
}
```

如果你想让配置对象是可选的，也很简单：

```js
function doSomething({ foo = 'Hi', bar = 'Yo!', baz = 13 } = {}) {
  // ...
}
```

## 3.对数组使用对象解构
使用对象解构把数组项赋值给特定的变量：

```js
const csvFileLine = '1997,John Doe,US,john@doe.com,New York';
const { 2: country, 4: state } = csvFileLine.split(',');
```

> 译注：这里把数组下标为 2 的值（`US`）赋给变量 `country`; 下标为 4 的值（`New York`）赋给变量 `state`。

## 4. switch 中使用范围
> 注意：经过一番思考，我决定把这个技巧和文中其他的区别开来。这个并不是一个节约时间的技巧，在真正代码中也不适合使用。记住：这种场景下使用 `if` 通常会更好。
和文中其他的技巧不同，这个方法主要是为了好奇而不是实用。
总之，由于历史原因我会保留这个技巧在这篇文章中。

这里有个简单的在 switch 语句中使用范围的技巧：

```js
function getWaterState(tempInCelsius) {
  let state;
  
  switch (true) {
    case (tempInCelsius <= 0): 
      state = 'Solid';
      break;
    case (tempInCelsius > 0 && tempInCelsius < 100): 
      state = 'Liquid';
      break;
    default: 
      state = 'Gas';
  }
  return state;
}
```

## 5. 使用 `async/await` 时，`await` 多个 `async` 函数

可以使用 `Promise.all` 来 `await` 多个 async 函数执行完成：

```js
await Promise.all([anAsyncCall(), thisIsAlsoAsync(), oneMore()])
```

## 6. 创建纯对象
你可以创建 100% 的纯对象（pure object）, 不继承 `Object` 的任何属性和方法（例如：`constructor`、`toString()` 等等）。

```js
const pureObject = Object.create(null);
console.log(pureObject); //=> {}
console.log(pureObject.constructor); //=> undefined
console.log(pureObject.toString); //=> undefined
console.log(pureObject.hasOwnProperty); //=> undefined
```

## 7. 格式化 JSON 代码

`JSON.stringify` 能做的不只是简单的字符串化对象，你还可以使用它来格式化 JSON 的输出：

```js
const obj = { 
  foo: { bar: [11, 22, 33, 44], baz: { bing: true, boom: 'Hello' } } 
};
// The third parameter is the number of spaces used to 
// beautify the JSON output.
JSON.stringify(obj, null, 4); 
// =>"{
// =>    "foo": {
// =>        "bar": [
// =>            11,
// =>            22,
// =>            33,
// =>            44
// =>        ],
// =>        "baz": {
// =>            "bing": true,
// =>            "boom": "Hello"
// =>        }
// =>    }
// =>}"
```

## 8. 数组去重

只使用 ES2015 的 `Set` 和展开运算符，就可以轻松实现数组去重：

```js
const removeDuplicateItems = arr => [...new Set(arr)];
removeDuplicateItems([42, 'foo', 42, 'foo', true, true]);
//=> [42, "foo", true]
```

## 9.扁平化多维数组
使用展开运算符可以轻松的扁平化数组：

```js
const arr = [11, [22, 33], [44, 55], 66];
const flatArr = [].concat(...arr); //=> [11, 22, 33, 44, 55, 66]
```

可惜的是，上面的这个技巧只对二维数组有效。但是通过递归，我们可以使它也适用于二维以上的数组：
```js
function flattenArray(arr) {
  const flattened = [].concat(...arr);
  return flattened.some(item => Array.isArray(item)) ? 
    flattenArray(flattened) : flattened;
}

const arr = [11, [22, 33], [44, [55, 66, [77, [88]], 99]]];
const flatArr = flattenArray(arr); 
//=> [11, 22, 33, 44, 55, 66, 77, 88, 99]
```

就这些啦！希望这些优雅的小技巧可以帮你写出更好更漂亮的 JavaScript。