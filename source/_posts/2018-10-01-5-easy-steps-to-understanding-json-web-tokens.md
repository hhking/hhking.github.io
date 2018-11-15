---
title: "[译] 简单 5 步，理解 JWT"
issue: 34
date: 2018-10-01 20:03:05
categories: [翻译]
tags: ["前端", "JSON Web Tokens", "JWT"]
---

> 原文: [5 Easy Steps to Understanding JSON Web Tokens (JWT)](https://medium.com/vandium-software/5-easy-steps-to-understanding-json-web-tokens-jwt-1164c0adfcec)
> 作者: [Mikey Stecky-Efantis](https://medium.com/@mikeysteckyefantis)
> 译者: [hhking](https://blog.hhking.cn/)

![](https://ws1.sinaimg.cn/large/006tNc79gy1fvqfflj9rkj31jk0q1tcx.jpg)

这篇文章，将会解释 JSON Web Tokens (JWT) 的基本原理以及为什么使用它们。JWT 是确保你的应用程序可信任和安全的重要部分。JWT 允许以安全的方式来表示信息，例如用户数据。

<!-- more -->

为了解释 JWT 的工作原理，我们从抽象的定义开始：

> JSON Web Token (JWT) 是一个 JSON 对象, 在 [RFC 7519](https://tools.ietf.org/html/rfc7519)  中定义为一种用来表示双方信息集的安全方式。Token 由头部 (header)、负载 (payload)、签名 (signature) 组成。

简单的说，JWT 只是形如下面格式的字符串：
```
header.payload.signature
```

*需要注意的是，双引号字符串也是合法的 JSON 对象*

为了说明如何使用和为什么使用 JWT，我们将用一个简单的 3 实体示例（参见下图）。例子里的三个实体分别是用户（user）、应用服务器（application server）、认证服务器（authentication server）。认证服务器提供 JWT 给用户，然后用户可以安全的和应用通信。

![](https://ws3.sinaimg.cn/large/006tNc79gy1fvqhw0cokfj318g0ukq4q.jpg)
<center>应用使用 JWT 校验用户真实性的过程</center><br>

在这个例子中，用户首先通过认证服务器提供的登录系统（例如：用户名和密码，Facebook 登录，Google 登录，等等）登录认证服务器。然后认证服务器生成 JWT 并返回给用户。当用户向应用服务器发起 API 请求时，会附带上 JWT。在这一步中，应用服务器会配置成去验证传入的 JWT 是否由认证服务器生成的（验证过程将在后面详细解释）。所以，当用户携带 JWT 发起 API 请求时，应用可以通过 JWT 来校验 API 请求是否来自认证的用户。

现在，我们将更加深入的研究 JWT 本身及其构建和验证的方式。

## Step 1. 创建 HEADER

JWT 的头部（header）模块包含了如何计算 JWT 签名的信息。header 是个 JSON 对象，格式如下：
```
{
    "typ": "JWT",
    "alg": "HS256"
}
```

这个 JSON 中，"type" 字段的值指明这个对象是个 JWT，"alg" 字段的值说明用什么 hash 算法来生成 JWT 签名模块。例子中，我们使用的是 HMAC-SHA256 算法 —— 带有密钥的 hash 算法，来计算签名（在 step 3 详细说明）。

## Step 2. 创建 PAYLOAD
JWT 的负载（payload）模块是存储在其中的数据（这个数据也被称为 JWT 的 “声明”）。在例子中，认证服务器生成 JWT，JWT 中保存了用户的信息，具体的说是用户 ID。

```
{
    "userId": "b08f86af-35da-48f2-8fab-cef3904660bd"
}
```

例子中，我们在 payload 中只保存了一个声明。你想要的话，也可以添加更多的声明。JWT 的 payload 有几种不同的标准声明，例如：“iss” 表示发行人, “sub” 表示主题, 以及 “exp” 表示过期时间。这些字段在创建 JWT 时非常有用，并且是可选的字段。可以在 [wikipedia page](https://en.wikipedia.org/wiki/JSON_Web_Token#Standard_fields) 上查看详细的 JWT 标准 字段列表。

要记住，数据的大小会影响整个 JWT 的大小，整个一般不是问题，但是太大的 JWT 可能会对性能有负面影响并导致延迟。

## Step 3. 创建 SIGNATURE
签名（signature）是有下面的伪代码计算得到的：

```
// signature algorithm
data = base64urlEncode( header ) + “.” + base64urlEncode( payload )
hashedData = hash( data, secret )
signature = base64urlEncode( hashedData )
```

这个算法做的是：对步骤 1 和 2 生成的 header 和 payload 进行 [base64url encodes](http://kjur.github.io/jsjws/tool_b64uenc.html) 编码，然后把编码生成的字符串中间通过句号（.）连接起来。在伪代码中，把连接的字符串赋值给 `data`。通过 JWT header 中定义的 hash 算法，加上密钥对 `data` 字符串 [hash](https://en.wikipedia.org/wiki/Hash_function) 处理。把 hash 后的数据赋值给 `hashedData`。这个 hash 后的数据通过 base64url 编码生成 JWT 签名（signature）。

我们的例子中，header 和 payload 被 base64url 编码成：
```
// header
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9
// payload
eyJ1c2VySWQiOiJiMDhmODZhZi0zNWRhLTQ4ZjItOGZhYi1jZWYzOTA0NjYwYmQifQ
```

然后，将编译后的 header 和 payload 进行拼接，使用指定的签名算法和密钥对它计算，得到签名需要的 hash 后的数据。在我们例子中，也就是使用 HS256 算法，密钥为字符串 `secret`，对字符串 `data` 计算得到字符串 `hashedData`。然后，通过 base64url 对字符串 `hashedData` 编码得到下面的 JWT 签名（signature）：

```
// signature
-xN_h82PHVTCMA9vdoHrcZxH-x5mb11y1537t3rGzcM
```

## Step 4. 将 JWT 三个模块合并

现在，我们已经创建了所有的三个模块，可以生成 JWT 了。记住 JWT 的结构 `header.payload.signature`，我们简单的使用句点（.）作为分隔来合并他们。我们使用 base64url 编码后的 header 和 payload，以及在 Step 3 得到的 signature：

```
// JWT Token
eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ1c2VySWQiOiJiMDhmODZhZi0zNWRhLTQ4ZjItOGZhYi1jZWYzOTA0NjYwYmQifQ.-xN_h82PHVTCMA9vdoHrcZxH-x5mb11y1537t3rGzcM
```

你可以使用 [jwt.io](https://jwt.io/) 去创建你的 JWT。

回到我们的例子，现在认证服务器可以把这个 JWT 发送给用户。

### JWT 是如何保护数据的
重要的是要理解，使用 JWT 的目的不是以任何方式隐藏或者模糊数据。使用 JWT 的目的是为了证明发送的数据是由可信的源创建的。

正如前面的步骤所示，JWT 里的数据被编码、签名，但是没有加密。编码数据的目的是为了转化数据的结构。签名数据是可以让数据接收者校验数据来源的可靠性。所以编码和签名数据并没有保护数据。而另一方面，加密的主要目的是保护数据和防止未授权访问。关于编码和加密的不同之处的详细解释，以及更多关于 hash 的原理，可以看 [这篇文章](https://danielmiessler.com/study/encoding-encryption-hashing-obfuscation/#encoding)。

> 由于 JWT 只是签名和编码数据，没有加密，所有 JWT 不保证敏感数据的任何安全性。

## Step 5. 校验 JWT
在我们的简单 3 实体实例中，我们使用的 JWT 是由 HS256 算法签名 —— 这个算法的密钥只有认证服务器和应用服务器知道。当应用服务器设置他的认证过程时，应用服务器从认证服务器那接收密钥。由于应用知道密钥，当用户向应用发起携带 JWT 的 API 请求时，应用可以执行和 Step 3 一样的签名算法。然后应用可以校验它自己 hash 操作生成的签名是否和 JWT 中的签名匹配（即它匹配认证服务器创建的 JWT 签名）。如果签名匹配，意味着 JWT 是合法的，标明 API 请求是来自可靠的来源。否则，如果签名不匹配，意味着接收的 JWT 是无效的，这也可能说明应用遭受潜在的攻击。所以，通过校验 JWT，应用在和用户之间建立了信任。

## 总结

我们了解了 JWT 是什么，如何创建和校验它，以及如何用它来建立应用和用户的信任。这是理解 JWT 的基本原理和它的作用的起点。JWT 只是确保应用中信任和安全性的难题之一。

需要指出的是，本文所述的 JWT 认证设置使用的是对称密钥算法（HS256）。你也可以用类似的方式来设置你的 JWT 认证，只是使用非对称算法（例如 RS256）—— 认证服务器有一个密钥，应用有一个公钥。关于使用对称和非对称算法的不同之处的详细分析，可以查看 [这个 Stack Overflow 上的问题](https://stackoverflow.com/questions/39239051/rs256-vs-hs256-whats-the-difference)。

同时要说明的是，JWT 必须通过 HTTPS 连接（不是 HTTP）来发送。使用 HTTPS 可以防止未授权用户窃取发送的 JWT，从而无法拦截服务端和用户之间的通信。

还有就是，给你的 JWT payload 设置有效期 —— 特别是很短的有效期，这个很重要，从而如果旧的 JWT 被泄漏，它可能已经无效并无法在使用了。

