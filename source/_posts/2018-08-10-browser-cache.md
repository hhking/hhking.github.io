---
title: 浏览器的缓存机制
date: 2018-08-10 14:36:08
categories: "前端"
tags: [前端,浏览器缓存]
issue: 19
---

相信很多前端都遇到过类似的情景：
为什么更新了内容，刷新页面没有生效？
被产品或测试追问：不是说问题解决了吗？为什么还是有问题？刷新也不行！

浏览器的缓存机制也就是HTTP缓存机制，是每个前端都必须理解一个点，了解浏览器缓存的机制，可以让我们在开发和排查问题中，避开很多坑；也能解释很多遇到的关于缓存的“神奇”问题；也可以针对缓存制定策略，做出优化，提升用户体验。

这里对浏览器缓存机制的学习做个总结和笔记！
<!-- more -->

## 缓存的作用
* 减少网络带宽消耗
* 缓解服务器压力
* 减少网络延迟，加快网页打开速度

## 缓存过程
浏览器和服务器进行通信的方式是：浏览器发起 HTTP 请求，服务器响应请求。浏览器是怎么决定是否缓存资源、怎么缓存？根据响应头！

缓存的大致过程如下：
1. 浏览器向服务器发起请求时，会先在浏览器缓存中查找该请求的结果和缓存标识，判断是否需要向服务器发起请求；
2. 拿到请求结果，会根据响应报文中 HTTP 头的缓存标识，决定是否缓存请求结果；
3. 浏览器每次拿到返回的请求结果都会将该结果和缓存标识存入浏览器缓存中；

根据是否需要向服务器重新发起 HTTP 请求将缓存过程分成：强制缓存和协商缓存。

### 强制缓存阶段(本地缓存)
#### 强制缓存过程
强制缓存阶段就是在浏览器缓存中查找请求结果和缓存标识，并根据该结果的缓存规则来决定是否使用该缓存结果的过程。

这个阶段有三种情况：
1. 没有查找到请求结果和缓存标识，则强制缓存失效，这时浏览器向服务器发起 HTTP 请求(第一次发起请求就属于这种情况)
![images](/images/browser-cache/browser-cache1.png)

2. 存在缓存标识，但是缓存已失效，则强制缓存不命中，这时使用协商缓存
![images](/images/browser-cache/browser-cache2.png)

3. 存在缓存结果和缓存标识，缓存结果有效，则命中强制缓存，直接返回缓存结果
![images](/images/browser-cache/browser-cache3.png)

#### 强制缓存规则
在强制缓存过程中，怎么判断缓存是否有效（也就是上面的情况 2 和 3）？
控制强制缓存的是响应报文中 HTTP 头的 Pragma、 Expires 和 Cache-Control 字段，其中 Cache-control 优先级最高。

##### Cache-Control
在 HTTP/1.1 中，Cache-Control 是最重要的规则，不仅是优先级最高，而且包含了 **缓存策略** 和 **过期策略**

语法为：```Cache-Control：cache-directive```，cache-directive 有如下取值(比较常见的是前五个)：

cache-directive | 说明
--------------- | ------------
public          | 所有内容都将被缓存（客户端和代理服务器都可以缓存）
private         | 所有内容只有客户端可以缓存，代理服务器不缓存，Cache-control 的默认取值
no-store        | 所有内容都不会被缓存，既不使用强制缓存，也不使用协商缓存
no-cache        | 客户端缓存内容，但是是否使用缓存需要通过协商缓存来验证决定(相当于 max-age:0,must-revalidate)
max-age         | 缓存内容将在 xxx 秒后失效（相对值）
s-maxage        | 同上, 覆盖 max-age, 且只在代理服务器上有效, 所以依赖 public 设置
max-stale       | 指定时间内, 即使缓存过时, 资源依然有效
min-fresh       | 缓存的资源至少要保持指定时间的新鲜期
must-revalidation / proxy-revalidation | 如果缓存失效, 强制重新向服务器(或代理)发起验证 (因为max-stale等字段可能改变缓存的失效时间)
only-if-cached  | 仅仅返回已经缓存的资源, 不向服务器请求, 若无缓存则返回504
no-transform    | 强制要求代理服务器不要对资源进行转换, 禁止代理服务器对 Content-Encoding, Content-Range, Content-Type字段的修改(因此代理的gzip压缩将不被允许)

*当 max-age 与 max-stale 和 min-fresh 同时使用时, 它们的设置相互之间独立生效, 但是客户端总是采用最保守的缓存策略*

##### Pragma
Pragma 是 http/1.0 字段, 通常设置为 Pragma:no-cache, 作用同 Cache-Control:no-cache. 为了向下兼容有些网站会加上这个配置；
在 chrome 开发者工具 Network 中, 勾选 Disable cache 时, 浏览器会自动带上了 Pragma 字段

##### Expires
Expires 是 HTTP/1.0 (现在浏览器默认使用的是 HTTP/1.1)控制网页缓存的字段，指定缓存到期的 GMT(格林尼治时间) 的绝对时间。
但是：响应报文中 Expires 所定义的缓存时间是相对服务器上的时间而言的，如果客户端的时间和服务端的时间不一致（比如用户自己修改了客户端时间），缓存时间就没有意义了。
为了解决这个问题，于是 HTTP/1.1 新增了 Cache-control 来定义缓存过期时间。

##### 启发式缓存
如果 Expires, Cache-Control: max-age, 或 Cache-Control:s-maxage 都没有在响应头中出现, 并且也没有其它缓存的设置, 那么浏览器默认会采用一个启发式的算法:
通常会取响应头的两个时间字段相减 Date - Last-Modified 值的 10% 作为缓存时间。

##### from memory cache/from disk cache
在 chrome 开发者工具 Network 中，我们经常会看到 200 from memory cache 或者 from disk cache ，这两个表示强制缓存成功。

200             | 描述            | 说明
--------------- | --------------- | ---
from memory     | 使用内存中的缓存  | 具有 **快速读取** (内存缓存会将编译解析后的文件，直接存入该进程的内存中)和 **实效性** (进程关闭会清空对应内存)的特点，js 和图片等文件解析执行后直接存入内存缓存中，刷新页面时只需直接从内存缓存中读取
from disk cache | 使用硬盘中的缓存  | css 文件则会存入硬盘文件中，每次渲染页面都需要从硬盘读取缓存

### 协商缓存阶段
#### 协商缓存过程
当强制缓存未命中(缓存过期)，浏览器携带缓存标识继续向服务器发起请求，服务器根据缓存标识决定是否使用缓存，这就是 **协商缓存**。
这个过程有下面两种情况：
1. 命中协商缓存，304
![images](/images/browser-cache/browser-cache4.png)
2. 未命中协商缓存，200
![images](/images/browser-cache/browser-cache5.png)

#### 协商缓存规则
控制协商缓存的字段有 Last-Modified/If-Modified-Since 和 Etag/If-None-Match, 其中 Etag/If-None-Match 的优先级比 Last-Modified/If-Modified-Since 高

#### Last-Modified/If-Modified-Since
  * Last-Modified 是服务器响应请求时，返回该资源文件在服务器最后被修改的时间
  * If-Modified-Since 是客户端再次发起该请求时，携带上次请求返回的 Last-Modified 值

服务器收到请求后, 拿 If-Modified-Since 字段的值与资源的 Last-Modified 值进行比较, 若相同, 则命中协商缓存, 返回304响应

#### Etag/If-None-Match
  * Etag 是服务器响应请求时，返回当前资源文件的一个唯一标识（服务器生成）
  * If-None-Match 是客户端再次发起请求时，携带上次请求返回的唯一标识 Etag 值

服务器收到请求后, 拿 If-None-Match 字段的值与资源的 ETag 值进行比较, 若相同, 则命中协商缓存, 返回304响应

#### Etag 解决 Last-Modified 无法解决的一些问题
  * 一些文件周期性更改，但是内容不变，只改变修改时间
  * 某些文件修改非常频繁，比如在秒以下的时间内进行修改，(比方说 1s 内修改了 N 次)，If-Modified-Since 能检查到的粒度是 s 级的，这种修改无法判断(或者说 UNIX 记录 MTIME 只能精确到秒)
  * 某些服务器不能精确的得到文件的最后修改时间

### 其他说明
  * Content-Length: 尽管并没有在缓存中明确涉及，Content-Length头部在设置缓存策略时很重要。某些软件如果不提前获知内容的大小以留出足够空间，则会拒绝缓存该内容。
  * Vary: 缓存系统通常使用请求的主机和路径作为存储该资源的键。当判断一个请求是否是请求同样内容是，Vary 头部可以被用来提醒缓存系统需要注意另一个附加头部。它通常被用来告诉缓存系统同样注意 Accept-Encoding 头部，以便缓存系统能够区分压缩和未压缩的内容。

## 总结
一图胜千言，在实际开发中，遇到缓存问题可以按下面的过程去思考问题。
![images](/images/browser-cache/browser-cache.png)

参考文章：
> [浏览器缓存机制剖析](http://louiszhai.github.io/2017/04/07/http-cache/)
> [彻底理解浏览器的缓存机制](https://heyingye.github.io/2018/04/16/%E5%BD%BB%E5%BA%95%E7%90%86%E8%A7%A3%E6%B5%8F%E8%A7%88%E5%99%A8%E7%9A%84%E7%BC%93%E5%AD%98%E6%9C%BA%E5%88%B6/)
> [HTTP/1.1: Header Field Definitions](https://www.w3.org/Protocols/rfc2616/rfc2616-sec14.html)
> [浅谈浏览器http的缓存机制](http://www.cnblogs.com/vajoy/p/5341664.html)

