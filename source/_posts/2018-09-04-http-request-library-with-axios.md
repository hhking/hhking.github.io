---
title: "[译] axios 内部设计分析"
issue: 27
date: 2018-09-04 20:06:10
categories: [翻译]
tags: ["前端", "Ajax", "源码分析"]
---

>原文: [How to Implement an HTTP Request Library with Axios](https://www.tutorialdocs.com/article/axios-learn.html)
>作者：Alex

## 概述
在前端开发过程中，我们经常遇到需要用到异步请求的场景。所以，一个功能齐全的 HTTP 请求库，可以极大的减少开发时间，提高开发效率。

axios 是近几年非常热门 HTTP 请求库。目前在 [Github](https://github.com/axios/axios) 已经有超过 40k 的 stars，也得到很多权威人士的推荐。

因此，有必要去了解一下 axios 是如何设计的、是如何实现 HTTP 请求库的。写这篇文章时 axios 的版本是 0.18.0，我们以此版本为例，来解读分析源码细节。axios 的源码是在 lib 目录下，以下涉及到的路径都是相对 `lib` 目录。

此篇主要讨论一下几点：
* 如何使用 axios
* axios 核心模块（请求 requests, 拦截器 interceptors, 撤销 withdrawals）的设计和实现方式
* axios 的设计优点

<!-- more -->

## 如何使用 axios
在理解 axios 的设计之前，我们先了解一下如何使用 axios。我们通过一个简单的例子来说明下面的 axios API。

### 发送请求
```js
axios({
  method:'get',
  url:'http://bit.ly/2mTM3nY',
  responseType:'stream'
})
  .then(function(response) {
  response.data.pipe(fs.createWriteStream('ada_lovelace.jpg'))
});
```
这是官方提供的 API 例子。从例子可以看出来，axios 的使用方式和 jQuery 的 ajax 非常相似，它们都返回 Promise （此例中 axios 也可以使用成功回调的方式，但是推荐使用 Promise 或者 await）来进行后续操作。

这个例子很简单，不需要过多解释，我们来看怎么添加 **过滤函数(filter function)**。

### 添加拦截函数
```js
// 添加一个请求拦截器
// 注意这里有两个方法 —— 一个成功时的和一个失败时的，后面会对这些做解释
axios.interceptors.request.use(function (config) {
    // 请求前的一些处理
    return config;
  }, function (error) {
    // 处理请求失败的情况
    return Promise.reject(error);
  });

// 添加一个响应拦截器
axios.interceptors.response.use(function (response) {
    // 处理响应的数据
    return response;
  }, function (error) {
    // 响应失败时的处理
    return Promise.reject(error);
  });
```

从上述代码可知：在请求前，可以对请求 `config` 的参数做处理；请求后响应时，也可以对返回的数据做些特殊处理。同时，在请求或者响应失败时，我们也可以做相应的特殊错误处理。

### 取消 HTTP 请求

在开发搜索相关的模块时，我们经常需要频繁发起数据搜索的请求。一般来说，在发起下一次请求时，我们要取消上一次的请求。同时也建议取消和请求相关联的函数调用。

```js
const CancelToken = axios.CancelToken;
const source = CancelToken.source();

axios.get('/user/12345', {
  cancelToken: source.token
}).catch(function(thrown) {
  if (axios.isCancel(thrown)) {
    console.log('Request canceled', thrown.message);
  } else {
    // handle error
  }
});

axios.post('/user/12345', {
  name: 'new name'
}, {
  cancelToken: source.token
})

// cancel the request (the message parameter is optional)
source.cancel('Operation canceled by the user.');
```
从上述例子可知，axios 使用基于 CancelToken 的撤销方式的提案。但是该提案已经被撤销了，[查看详情](https://github.com/tc39/proposal-cancelable-promises)。撤销的实现细节在后面的源码分析部分会解释。

## axios 核心模块的设计和实现方式

通过上面的例子，相信大家对 axios 的使用有了一个大致的了解。下面，我们根据 axios 的模块来分析其设计和实现。下图展示了该博文涉及到的 axios 相关目录。如果你感兴趣的话，建议 clone 相关的代码来看，这样可以对相应的模块有更深的理解。

![images](https://www.tutorialdocs.com/upload/2018/08/axios-module.png)

### HTTP 请求模块（HTTP request module）

和请求模块相关的代码在 `core/dispatchReqeust.js` 文件中。这里我选取了部分关键源码来做简单的介绍：

```js
// core/dispatchReqeust.js
module.exports = function dispatchRequest(config) {
    throwIfCancellationRequested(config);

    // other source code

    // 默认的适配器模块是根据当前环境来选择使用 Node 或者 XHR 来发起请求
    var adapter = config.adapter || defaults.adapter; 

    return adapter(config).then(function onAdapterResolution(response) {
        throwIfCancellationRequested(config);

        // other source code

        return response;
    }, function onAdapterRejection(reason) {
        if (!isCancel(reason)) {
            throwIfCancellationRequested(config);

            // other source code

            return Promise.reject(reason);
        });
};
```

通过上面的代码可知，`dispatchRequest` 方法是用来获取发送请求模块，发送请求模块是通过 `config.adapter` 得到。我们也可以通过传入符合规范的适配器函数（adapter function）来代替原始的模块（我们一般不会这么做，但是这是一个低耦合扩展点）。

在 `default.js` 文件里，可以看到 `adapter` 生成的逻辑：通过一些特殊的属性和当前执行环境的构造函数来判断。

```js
// default.js
function getDefaultAdapter() {
    var adapter;
    // Only Node.js has the classes of which variable type is process.
    if (typeof process !== 'undefined' && Object.prototype.toString.call(process) === '[object process]') {
        // Node.js request module.
        adapter = require('./adapters/http');
    } else if (typeof XMLHttpRequest !== 'undefined') {
        // The browser request module.
        adapter = require('./adapters/xhr');
    }
    return adapter;
}
```

axios 里的 XHR 模块是对 `XMLHTTPRequest` 对象的封装，相对比较简单。所以这里不会过多的说明，有兴趣的话可以自己去阅读，代码在 `adapters/xhr.js` 文件。

### 拦截器模块（Interceptor module）

现在来看看 axios 是如何实现请求和响应的拦截器方法。先来看看 axios 的统一接口 —— `request` 函数。

```js
// core/Axios.js
Axios.prototype.request = function request(config) {

    // other code

    var chain = [dispatchRequest, undefined];
    var promise = Promise.resolve(config);

    this.interceptors.request.forEach(function unshiftRequestInterceptors(interceptor) {
        chain.unshift(interceptor.fulfilled, interceptor.rejected);
    });

    this.interceptors.response.forEach(function pushResponseInterceptors(interceptor) {
        chain.push(interceptor.fulfilled, interceptor.rejected);
    });

    while (chain.length) {
        promise = promise.then(chain.shift(), chain.shift());
    }

    return promise;
};
```

这个函数是 axios 发送请求的接口。因为这个功能实现相对较长，所以我简要介绍一下相关的设计思路：
1. chain 是执行队列。队列的初始值是一个带 config 参数的 Promise。
2. chain 执行队列中，插入了两个值，一个是用来发送请求的初始化函数 `dispatchRequest`，一个是
和 `dispatchRequest` 配对的函数 `undefined`。为什么要加 `undefined` 呢？因为在 Promise 里需要一个成功回调和一个失败回调，从代码段 `promise = promise.then(chain.shift(), chain.shift());` 也可以看出来。所以，`dispatchRequest` 和 `undefined` 可以当成是成对的函数。
3. `chain` 执行队列中，发送请求的 `dispatchRequest` 函数位于“中间位置”。在它的前面是请求拦截器，通过 `unshift` 方法插入；在 `dispatchRequest` 后面的是响应拦截器，通过 `push` 方法插入。需要注意的是这些方法都是成对添加的，也就意味着一次会添加两个方法。

通过上述 `request` 的代码，我们大致知道怎么使用拦截器了。现在我们来看看怎么取消 HTTP 请求。

### 取消请求模块（Cancel-request module）
和取消相关的模块在 `Cancel/` 目录。现在来看一下相关的核心代码。

首先来看一下元类 `Cancel`。这个类是用来标记取消状态。代码细节如下：

```js
// cancel/Cancel.js
function Cancel(message) {
  this.message = message;
}

Cancel.prototype.toString = function toString() {
  return 'Cancel' + (this.message ? ': ' + this.message : '');
};

Cancel.prototype.__CANCEL__ = true;
```

在 `CancelToken` 类中，通过传递 Promise 方法来实现 HTTP 请求的取消，具体代码如下：

```js
// cancel/CancelToken.js
function CancelToken(executor) {
    if (typeof executor !== 'function') {
        throw new TypeError('executor must be a function.');
    }

    var resolvePromise;
    this.promise = new Promise(function promiseExecutor(resolve) {
        resolvePromise = resolve;
    });

    var token = this;
    executor(function cancel(message) {
        if (token.reason) {
            // Cancellation has already been requested
            return;
        }

        token.reason = new Cancel(message);
        resolvePromise(token.reason);
    });
}

CancelToken.source = function source() {
    var cancel;
    var token = new CancelToken(function executor(c) {
        cancel = c;
    });
    return {
        token: token,
        cancel: cancel
    };
};
```

相关的取消请求的代码在 `adapter/xhr.js` 文件:

```js
// adapter/xhr.js
if (config.cancelToken) {
    // Wait for the cancellation.
    config.cancelToken.promise.then(function onCanceled(cancel) {
        if (!request) {
            return;
        }

        request.abort();
        reject(cancel);
        // Reset the request.
        request = null;
    });
}
```

通过上述取消 HTTP 请求的代码，我们简要的解释一下相关实现逻辑：
1. 在需要取消的请求中，调用 `source` 方法来初始化，该方法会返回 `CancelToken` 类的实例 A 和 `cancle` 方法。
2. 当 `source` 方法返回实例 A 时，会初始化一个处于 `pending` 状态的 promise。然后把实例 A 传递给 axios，promise 就可以当做取消请求的触发器。
3. 当调用 `source` 方法返回的 `cancel` 方法时，实例 A 中的 promise 从 pending 转化成 fulfilled 状态，然后马上触发回调函数。从而 axios 的取消逻辑 —— `request.abort()` 被触发。

## axios 的设计优点

### 发送请求函数的处理逻辑
正如前面章节提到的，axios 并没有把发送请求的 `dispatchRequest` 函数当成特殊函数对待。实际上，`dispatchRequest` 函数放在队列的中间，从而保证队列处理的一致性并提高代码的可读性。

### 适配器的处理逻辑
在适配器的的处理逻辑中，`http` 和 `xhr` 模块（`http` 用于 Node.js 发送请求，`xhr` 用于浏览器发送请求）并不直接放在 `dispatchRequest` 模块中，而是通过默认配置从 `default.js` 引入。从而不仅可以保证两个模块的低耦合，而且为将来的用户预留了定制化请求的空间。

### 取消 HTTP 请求的处理逻辑
在取消 HTTP 请求的逻辑中，axios 设计使用 Promise 作为触发器，把 `resolve` 方法作为 `callback` 的参数传递到外面。这样不仅确保内部逻辑的一致性，还可以确保在需要取消请求时，不必直接修改相关类的样本数据，从而可以最大程度避免侵入其他的模块。

## 总结
本文详细介绍了 axios 的使用，设计思路和实现方法。阅读后，你可以知道 axios 的设计，同时学习模块的封装和交互。

本文只介绍了 axios 的核心模块。如果你对其他源码感兴趣，你可以去 [Github](https://github.com/axios/axios) 上查看。


*在 [阮一峰每周分享第 20 期](http://www.ruanyifeng.com/blog/2018/08/weekly-issue-20.html) 看到这篇文章。文章没有很复杂的东西，也不是很细致的使用说明或者源码解读，作者主要是对 axios 内部设计进行分析，从整体上了解其中的核心设计思想。翻译可能有不准确或者错误地方，欢迎指正！*
