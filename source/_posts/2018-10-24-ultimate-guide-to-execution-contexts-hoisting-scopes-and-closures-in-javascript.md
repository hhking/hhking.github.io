---
title: "[译]JavaScript 终极指南之执行上下文、变量提升、作用域和闭包"
issue: -1
date: 2018-10-24 23:18:37
categories: [翻译]
tags: ["JavaScript", "执行上下文", "Execution Contexts", "变量提升", "Hoisting", "作用域", "Scopes", "闭包", "Closures"]
---

> 原文：[The Ultimate Guide to Execution Contexts, Hoisting, Scopes, and Closures in JavaScript](https://tylermcginnis.com/ultimate-guide-to-execution-contexts-hoisting-scopes-and-closures-in-javascript/)
> 作者：[Tyler McGinnis](https://twitter.com/tylermcginnis)

![](https://ws1.sinaimg.cn/large/006tNbRwgy1fwh0zvi9tcj30zk0k0tac.jpg)

视频：[The Ultimate Guide to Execution Contexts, Hoisting, Scopes, and Closures in JavaScript](https://www.youtube.com/watch?v=Nt-qa_LlUH0)

我认为理解 JavaScript 语言的最重要的基本概念是理解执行上下文（Execution Context），这点可能令人感到意外。正确的学习执行上下文，可以让你更容易学习更高级的内容，比如变量提升（hoisting）、作用域链（scope chains）和闭包（closures）。既然如此，那到底什么是“执行上下文”呢？为了更好的理解它，我们先来看看我们是如何写软件的。

<!-- more -->

编写软件的一种策略是把代码拆分成独立的块。虽然这些“块”有不同的命名（函数、模块、包等等），但是他们有同样的目的——分解和处理应用的复杂性。现在我们不要以编写代码的思维来思考，而是以 JavaScript 引擎的角度来思考，JavaScript 引擎是用来解释代码的。那么我们是否也可以使用和我们在写代码的时候一样的策略，把代码拆分成块，来处理解释代码的复杂性。答案是可以，这些“块”被称为执行上下文。**正如可以使用函数、模块、包（functions/modules/packages）来处理编写代码的复杂性，JavaScript 引擎可以通过执行上下文来处理解释和运行代码的复杂性。** 现在我们知道执行上下文的用途了，接下来需要解答的问题是：它们是如何创建的和它们是什么组成的？

JavaScript 引擎执行代码时，第一个被创建的执行上下文叫做全局执行上下文（Global Execution Context）。最开始这个执行上下文包含两个东西——一个全局对象和 `this` 变量。`this` 会引用全局对象，在浏览器执行 JavaScript 则全局对象是 `window`，在 Node 环境执行则全局对象是 `global`。

![](https://ws2.sinaimg.cn/large/006tNbRwgy1fwh47egir8j31b40m474s.jpg)

上图我们可以看到，即使没有任何代码，全局执行上下文还是会包含两个东西—— `window` 和 `this`。这是全局执行上下文的最基本形式。

我们一步一步来，看看当向程序添加代码时会发生什么。我们先添加一些变量。

![](https://ws3.sinaimg.cn/large/006tNbRwgy1fwh4d1ivpsj31is0rudhu.jpg)

![](https://ws3.sinaimg.cn/large/006tNbRwgy1fwh4dajq5dj31is0rutar.jpg)

你可以看出上面两张图的不同之处吗？关键的是每个执行上下文都有两个独立的阶段——创建（`Creation`）阶段和执行（`Execution`）阶段，每个阶段都有它特有的职责。

在全局`创建`阶段，JavaScript 引擎将会：
1. 创建全局对象
2. 创建 `this` 对象
3. 给变量和函数设置内存空间
4. 变量声明并默认赋值为 `undefined`，同时在内存中放置所有函数声明。

直到`执行`阶段，JavaScript 引擎才会开始一行一行的执行代码。

我们从下面的 GIF 图可以看到从`创建`阶段到`执行`阶段这一流程。

![](https://tylermcginnis.com/images/posts/advanced-javascript/global-execution-context-gif.gif)

在`创建`阶段，创建 `window` 和 `this` ，变量声明（`name` 和 `handle`）默认赋值为 `undefined`，所有函数声明（`getUser`）全部放入内存中。然后一旦进入 `执行` 阶段，JavaScript 引擎开始一行一行的执行代码，然后给内存中已存在的变量赋上真实的值。

> Gif 很酷，但是一步一步执行代码并亲自查看执行过程更酷。我为你创建了 [JavaScript Visualizer](https://tylermcginnis.com/javascript-visualizer/)，你值得拥有。如果你想查看上面的确切代码，打开这个[链接](https://tylermcginnis.com/javascript-visualizer/?code=var%20name%20%3D%20%27Tyler%27%0Avar%20handle%20%3D%20%27%40tylermcginnis%27%0A%0Afunction%20getUser%20%28%29%20%7B%0A%20%20return%20%7B%0A%20%20%20%20name%3A%20name%2C%0A%20%20%20%20handle%3A%20handle%0A%20%20%7D%0A%7D)。

为了真正巩固 `创建` 阶段和 `执行` 阶段的知识点，我们打印一些 `创建` 阶段之后和 `执行` 阶段之前的值出来。

```js
console.log('name: ', name)
console.log('handle: ', handle)
console.log('getUser :', getUser)

var name = 'Tyler'
var handle = '@tylermcginnis'

function getUser () {
  return {
    name: name,
    handle: handle
  }
}
```

在上面的代码，你想在 console 中打印出什么？当 JavaScript 开始一行一行执行代码和调用 `console.log` 时，`创建` 阶段已经完成了。这意味着，正如之前看到的，变量声明已经赋值为 `undefined` ，而函数声明则整个放在内存中了。所以正如我们期望的那样，`name` 和 `handle` 值为 `undefined`，`getUser` 引用内存中的函数。

```js
console.log('name: ', name) // name: undefined
console.log('handle: ', handle) // handle: undefined
console.log('getUser :', getUser) // getUser: ƒ getUser () {}

var name = 'Tyler'
var handle = '@tylermcginnis'

function getUser () {
  return {
    name: name,
    handle: handle
  }
}
```

> 在创建阶段给变量声明默认赋值为 `undefined` 的过程称为***变量提升（`Hoisting`）***

之前你可能尝试过向自己解释“变量提升”，但是不尽人意。“变量提升”令人迷惑的点在于实际上没有任何东西“提升”或者移动。现在你理解了执行上下文和变量声明在 `创建` 阶段默认赋值为 `undefined`，从而你也理解了“变量提升”，因为这就是“变量提升”。

---

现在，你应该对全局执行上下文和它的两个阶段——`创建` 和 `执行`相当熟悉了。好消息是只剩一个其他的执行上下文你需要学习，而且它几乎和全局执行上下文完全相同。它就是函数执行上下文，它在函数**调用**的时候创建。

关键的是，执行上下文只有在 JavaScript  引擎第一次开始解释代码时（全局执行上下文）或者函数调用时才创建。

现在主要的问题是，全局执行上下文和函数执行上下文的不同点是什么？如果你还记得，之前提到过在全局 `创建` 阶段，JavaScript 引擎将会：

1. 创建全局对象
2. 创建 `this` 对象
3. 为变量和函数设置内存空间
4. 变量声明默认赋值为 `undefined`，同时函数声明存入内存

这些步骤对于函数执行上下文来说哪些是不对的？步骤 1。我们有且只有一个全局对象，它在全局执行上下文的 `创建` 阶段创建，而不会在函数调用和 JavaScript 引擎创建函数执行上下文时创建。函数执行上下文不需要创建全局变量，而是需要考虑参数（arguments）问题，而全局执行上下文没有这个问题。考虑到这些，我们可以调整之前的列表。当**函数**执行上下文创建时，JavaScript 引擎将会：

1. ~~创建全局对象~~
1. 创建一个参数对象
2. 创建 `this` 对象
3. 为变量和函数设置内存空间
4. 变量声明默认赋值为 `undefined`，同时函数声明存入内存

我们回到之前提到的代码，来看看这个过程，但是这次除了定义 `getUser`，还要看看调用它时会发生什么。

> [查看可视化代码](https://tylermcginnis.com/javascript-visualizer/?code=var%20name%20%3D%20%27Tyler%27%0Avar%20handle%20%3D%20%27%40tylermcginnis%27%0A%0Afunction%20getUser%20%28%29%20%7B%0A%20%20return%20%7B%0A%20%20%20%20name%3A%20name%2C%0A%20%20%20%20handle%3A%20handle%0A%20%20%7D%0A%7D%0A%0AgetUser%28%29)

![](https://tylermcginnis.com/images/posts/advanced-javascript/function-execution-context-gif.gif)

正如我们所说，调用 `getUser` 时会创建新的执行上下文。在 `getUser` 执行上下文的 `创建` 阶段，JavaScript 引擎创建 `this` 对象和 `arguments` 对象。因为 `getUser` 没有任何变量，所以 JavaScript 不需要给变量设置内存空间和进行“提升”。

你可能也注意到，当 `getUser` 函数执行完，它在可视化图里被移除了。实际上，JavaScript 引擎创建了“执行栈”（也被成为“调用栈”）。当函数调用时，创建新的执行上下文并把它加入执行栈。当函数执行结束，完成了 `创建` 和 `执行` 阶段，它会从执行栈中弹出。因为 JavaScript 是单线程的（意味着同时只能执行一个任务），所以这个过程很容易实现可视化。使用 “JavaScript Visualizer”，执行栈以嵌套形式显示，每个嵌套项对应执行栈中的新的执行上下文。

> [查看可视化代码](https://tylermcginnis.com/javascript-visualizer/?code=function%20a%20%28%29%20%7B%0A%20%20console.log%28%27In%20fn%20a%27%29%0A%20%20%0A%20%20function%20b%20%28%29%20%7B%0A%20%20%20%20console.log%28%27In%20fn%20b%27%29%0A%20%20%20%20%0A%20%20%20%20function%20c%20%28%29%20%7B%0A%20%20%20%20%20%20console.log%28%27In%20fn%20c%27%29%0A%20%20%20%20%7D%0A%20%20%20%20%0A%20%20%20%20c%28%29%0A%20%20%7D%0A%0A%20%20b%28%29%0A%7D%0A%0Aa%28%29)

![](https://tylermcginnis.com/images/posts/advanced-javascript/javascript-execution-stack.gif)

---

现在，我们已经知道函数调用如何创建自己的执行上下文，并加入执行栈中。我们还不知道的是有局部变量时会怎么样。我们修改代码，让函数有局部变量。

> [查看可视化代码](https://tylermcginnis.com/javascript-visualizer/?code=var%20name%20%3D%20%27Tyler%27%0Avar%20handle%20%3D%20%27%40tylermcginnis%27%0A%0Afunction%20getURL%20%28handle%29%20%7B%0A%20%20var%20twitterURL%20%3D%20%27https%3A%2F%2Ftwitter.com%2F%27%0A%0A%20%20return%20twitterURL%20%2B%20handle%0A%7D%0A%0AgetURL%28handle%29)

![](https://tylermcginnis.com/images/posts/advanced-javascript/local-variables.gif)

这里有一些重要的细节要注意。第一点是，你传入的任何参数都会作为局部变量添加到函数的执行上下文。在例子中，`handle` 作为变量出现在 `全局` 执行上下文（在变量定义的地方），也出现在 `getURL` 执行上下文中，因为把它当做参数传入了。然后是，函数内部声明的变量，存在于函数执行上下文中。所以当我们创建 `twitterURL` 时，它存在于 `getURL` 执行上下文——它定义的地方，而不在 `全局` 执行上下文中。这点看起来很明显，但它是我们下个主题——作用域的基本原理。

---

过去，你可能听到过对“作用域”的定义，即为“可访问到变量的地方”。现在不管这个定义是否正确，使用你新学到的知识——执行上下文和 JavaScript Visualizer 工具，作用域的概念会变得比之前更加清晰。实际上，MDN 将 “作用域” 定义为 “当前执行的上下文”。听起来很熟悉？我们可以用类似执行上下文的思维来思考“作用域”和“可访问到变量的地方”。

这里有个测试。下面代码中，`bar` 会打印出什么？

```js
function foo () {
  var bar = 'Declared in foo'
}

foo()

console.log(bar)
```

我们用 JavaScript Visualizer 来验证。

> [查看可视化代码](https://tylermcginnis.com/javascript-visualizer/?code=function%20foo%20%28%29%20%7B%0A%20%20var%20bar%20%3D%20%27Declared%20in%20foo%27%0A%7D%0A%0Afoo%28%29%0A%0Aconsole.log%28bar%29)

![](https://tylermcginnis.com/images/posts/advanced-javascript/scope.gif)

`foo` 调用时，我们在执行栈中创建新的执行上下文。在 `创建` 阶段创建 `this`、`arguments`，并给 `bar` 赋值为 `undefined`。然后开始 `执行` 阶段，把字符串 `Declared in foo` 赋值给 `bar`。在 `执行` 阶段结束后，`foo` 执行上下文从栈中弹出。当 `foo` 从执行栈中移除时，我们尝试在 console 中打印 `bar`。此时通过 JavaScript Visualizer，发现 `bar` 好像是从来没有出现过，所以我们得到 `undefined`。这个告诉我们，函数内部定义的变量是局部作用域的。这意味着（对大多数而已，后面会看到例外的情况）一旦函数执行上下文从执行栈弹出，变量就无法访问到了。

下面是另一个测试。下面的代码执行完之后 console 会打印出什么？

```js
function first () {
  var name = 'Jordyn'

  console.log(name)
}

function second () {
  var name = 'Jake'

  console.log(name)
}

console.log(name)
var name = 'Tyler'
first()
second()
console.log(name)
```

我们还是来看看 JavaScript Visualizer。

> [查看可视化代码](https://tylermcginnis.com/javascript-visualizer/?code=function%20first%20%28%29%20%7B%0A%20%20var%20name%20%3D%20%27Jordyn%27%0A%0A%20%20console.log%28name%29%0A%7D%0A%0Afunction%20second%20%28%29%20%7B%0A%20%20var%20name%20%3D%20%27Jake%27%0A%0A%20%20console.log%28name%29%0A%7D%0A%0Aconsole.log%28name%29%0Avar%20name%20%3D%20%27Tyler%27%0Afirst%28%29%0Asecond%28%29%0Aconsole.log%28name%29)

![](https://tylermcginnis.com/images/posts/advanced-javascript/unique-scopes.gif)

我们得到的结果是：`undefined`、`Jordyn`、`Jake` 和 `Tyler`。这个告诉我们，我们可以认为每个新的执行上下文有它自己的特有的变量环境。即使还有其他执行上下文包含变量 `name`，JavaScript 引擎会先从当前执行上下文查找变量。

这就引出新的问题，如果当前执行上下文中不存在变量怎么办？JavaScript 引擎是否就停止查找该变量？我们来看个例子，它会告诉我们答案。下面的代码，会打印什么结果？

```js
var name = 'Tyler'

function logName () {
  console.log(name)
}

logName()
```

> [查看可视化代码](https://tylermcginnis.com/javascript-visualizer/?code=var%20name%20%3D%20%27Tyler%27%0A%0Afunction%20logName%20%28%29%20%7B%0A%20%20console.log%28name%29%0A%7D%0A%0AlogName%28%29)

可能直觉告诉你会打印 `undefined`，因为 `logName` 执行上下文的作用域下没有 `name` 变量。这样想是正常的，但是是错误的。如果 JavaScript 引擎在函数执行上下文中找不到变量会发生什么呢？它会在最近的父级执行上下文中查找该变量。这个查找链将会一直持续，直到引擎查找到全局执行上下文。这种情况下，如果全局执行上下文也没有该变量，那么将会抛出引用错误（Reference Error）。

> 如果变量在局部执行上下文中不存在，JavaScript 引擎会逐个检查各自的父级执行上下文，这个过程称为 `作用域链`。在 JavaScript Visualizer 中显示，每个新的执行上下文添加了缩进并加上特别的背景颜色。通过可视化，你可以看到每个子级执行上下文可以引用它父级执行上下文中的任何变量，但是反之则不行。

---

前面我们学习到，函数内部定义的变量是局部作用域的，当函数执行上下文从执行栈弹出后，变量就无法访问了（针对大多数情况）。这个说法错误的一种情况是：当一个函数内嵌在另一个函数里时。这种情况下，即使父级函数的执行上下文已经从执行栈中移除，子函数也可以保持能访问外部函数作用域。这个说起来就复杂了。还是使用 JavaScript Visualizer，它可以帮助我们。

> [查看可视化代码](https://tylermcginnis.com/javascript-visualizer/?code=var%20count%20%3D%200%0A%0Afunction%20makeAdder%28x%29%20%7B%0A%20%20return%20function%20inner%20%28y%29%20%7B%0A%20%20%20%20return%20x%20%2B%20y%3B%0A%20%20%7D%3B%0A%7D%0A%0Avar%20add5%20%3D%20makeAdder%285%29%3B%0Acount%20%2B%3D%20add5%282%29)

![](https://tylermcginnis.com/images/posts/advanced-javascript/closure-scope.gif)

在 `makeAdder` 执行上下文在执行栈弹出后，JavaScript Visualizer 创建了 `闭包作用域（Closure Scope）`。在 `闭包作用域（Closure Scope）` 里拥有和 `makeAdder` 执行上下文里一样的变量环境。产生这个情况的原因是，我们在把函数嵌入到另一个函数里。在我们这个例子里，函数 `inner` 内嵌在函数 `makeAdder` 里，所以 `inner` 创建了包含 `makeAdder` 变量环境的 `闭包`。因为创建了`闭包作用域（Closure Scope）`，所以即使 `makeAdder` 执行环境已经从执行栈弹出了，`inner` 还是可以访问变量 `x`（通过作用域链）。

正如你所想，子函数“包含”它父级函数的变量环境，把这个概念称为“闭包”。

