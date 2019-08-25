---
title: HTTP 和安全相关的头信息
subtitle: HTTP Security Headers
issue: 46
date: 2019-08-25 17:01:33
categories: ['前端']
tags: ['前端', 'HTTP']
---

## 前言
WEB 应用越来越复杂，前端所承担的也不再仅仅是切图、写界面的任务。作为一个前端工程师，掌握必要的 WEB 安全相关的知识，也是必要的。
这里收集整理了 HTTP 中和安全相关的头信息内容，了解这些头信息，在提升网站的安全性上，是有不少帮助的。

## 安全相关的头信息

### Content-Security-Policy

内容安全策略 CSP (Content-Security-Policy) 的主要目的是减少和报告 XSS 攻击。

实现的方式是通过白名单机制，也就是提供可信赖的外部资源来源的白名单，浏览器根据白名单来获取资源。

来看下 MDN 上提供的一个例子：

```
Content-Security-Policy: default-src 'self'; img-src *; media-src media1.com media2.com; script-src userscripts.example.com; report-uri http://reportcollector.example.com/collector.cgi
```

`default-src 'self';`: 表示各种内容允许从文档所在的源获取(不包括其子域名)
`img-src *;`: 图片可以从任何地方加载
`media-src media1.com media2.com;`: 多媒体文件仅允许从 media1.com 和 media2.com 加载(不包括其子域名)
`script-src userscripts.example.com`: 可运行脚本仅允许来自于userscripts.example.com
`report-uri`: 设置这个选项，表示启用发送违规报告，也就是会把违规的信息 (JSON 格式) 发送到配置的 URI 地址

> 参考:
>
> [CSP Reference](https://content-security-policy.com/)
> [内容安全策略( CSP )](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/CSP)



### Strict-Transport-Security

如果你的网站启动了 HTTPS，可以使用这个配置，告诉浏览器你的网站只能通过 HTTPS 来访问。

作用：例如我们在访问 HTTP 网站时，网站再自动跳转到 HTTPS，这个过程中，存在中间人攻击潜在威胁，因为在跳转到 HTTPS 之前，用户信息是未加密的。配置 STS 可以让浏览器自动替换 HTTP 为 HTTPS 请求。

示例：

```
Strict-Transport-Security: max-age=1000; includeSubDomains
```

`max-age`: 设置在浏览器收到这个请求后的 1000 秒的时间内凡是访问这个域名下的请求都使用HTTPS请求。

`includeSubDomains` 该网站的所有子域名也启用该规则。



> 参考：[HTTP Strict Transport Security](https://developer.mozilla.org/zh-CN/docs/Security/HTTP_Strict_Transport_Security)



### X-Content-Type-Options

我们知道，浏览器会根据响应头的 [`Content-Type`](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Content-Type) 来辨别请求资源的类型，例如：` "`text/css`"` 表示 `style` 类型。但是如果不指定 MIME 类型或者指定错误，浏览器会进行 [MIME 类型嗅探](https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types#MIME_sniffing)，猜测资源的类型，然后进行解析。而这个行为可能会被恶意攻击。

配置方式如下:

```
X-Content-Type-Options: nosniff
```

作用：通过这个配置，可以让浏览器按服务端返回的指定类型进行内容解析。



> 参考：[X-Content-Type-Options](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/X-Content-Type-Options)



### X-Frame-Options

这个响应头是用来告诉浏览器，这个页面是否可以被 `<frame>`, ` <iframe>`, `<embed>`, `<object>` 嵌入。

作用：网站可以避免被嵌入到别人的网站中，从而避免点击劫持  (clickjacking)。

配置示例：

```
X-Frame-Options: deny
```

> 注意：这个功能，也可以通过 CSP 中配置 `frame-ancestors: none` 来实现，以后可能会慢慢淘汰非标准的 `X-Frame-Options`
>
> 参考：[X-Frame-Options 响应头](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/X-Frame-Options)



### X-XSS-Protection

顾名思义，这个是用来设置防御 XSS 攻击的。目前这个一般浏览器都是默认开启的。

配置示例：

```
X-XSS-Protection: 1; mode=block
```

作用：这个配置启用 XSS 过滤，如果检测到有 XSS 攻击，阻止页面加载。

> 参考：[X-XSS-Protection](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/X-XSS-Protection)



### Set-Cookie

`Set-Cookie` 中的 `Secure` 和 `HttpOnly` 配置是用来保证 cookie 的安全的。

`Secure`: 配置这个安全属性，让 cookie 只在 HTTPS 中加密传输。

`HttpOnly`: 这个配置可以禁止通过 JavaScript 来访问 cookie，防止 XSS 攻击。

> 参考：[Set-Cookie](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Set-Cookie)



### Access-Control-Allow-Origin

这个响应头前端会比较熟悉，因为跨域请求里 (CORS)，就和这个有关系。

通过配置这个响应头，可以指定哪些域有权限访问该资源。

配置方法：

```
Access-Control-Allow-Origin: <origin>|*
```

> 参考：[Access-Control-Allow-Origin](https://developer.mozilla.org/zh-CN/docs/Web/HTTP/Headers/Access-Control-Allow-Origin)



### Cache-Control && Expires

这个其实是属于缓存配置，但是，我们需要注意的是，针对一些具有敏感数据，例如用户信息、交易页面，这些不应该配置缓存，以免因为页面缓存而导致敏感信息的泄露。

> 具体配置可以看之前的文章：[浏览器的缓存机制](https://blog.hhking.cn/2018/08/10/browser-cache/)



## 总结

这些 HTTP 安全配置，有助于提升网站的安全性，而从这些配置里，我们也能学到一些安全防御方面的思路：
- 传输信息加密
- XSS 过滤
- 白名单机制
- 同源策略



## 参考资料

> [HTTP Security Headers - A Complete Guide](https://nullsweep.com/http-security-headers-a-complete-guide/)
> [一些安全相关的HTTP响应头](https://imququ.com/post/web-security-and-response-header.html)
