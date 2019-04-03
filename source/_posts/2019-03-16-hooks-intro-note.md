---
title: "React Hooks 阅读笔记 —— Hooks 简介"
issue: 41
date: 2019-03-16 15:03:51
categories: ["React"]
tags: ["React", "React Hooks"]
---

> 官方文档关于 Hooks 的阅读笔记

## 关于 Hooks

- 这是个可选的功能。如果你不想用，你可以选择忽略它。

- 100% 向后兼容。Hooks 没有破坏性的变更。

- 现在已经可以使用了。Hooks 在 React V16.8.0 已经发布。

<!-- more -->

## Hooks 要解决的问题

### 组件之间的状态逻辑复用
`render props` 和 `higer-order components` 模式，也是为了解决这个问题而出现的。但是，这两种模式需要重构代码来实现，并且在 chrome 调试的时候，你会发现 `React DevTools` 中组件会多了很多层嵌套（`wrapper hell`）。

使用 Hooks，可以让你不改变组件层级就可以复用状态逻辑。这样使用起来更加自然，也更容易理解。

### 复杂组件变得越来越难理解
随着需求的增加，组件越来越复杂，而且很多的逻辑处理（例如数据获取、事件绑定和解绑）依赖于生命周期函数，但是这些逻辑本身互相无关，这也就会出现一个生命周期的方法里混杂着互不相关的处理逻辑，导致组件越来越难以理解，从而导致出错的概率增加。

Hooks 可以实现组件更小粒度的函数拆分，互相无关的逻辑也可以区分开来，而不用再依赖生命周期方法来进行拆分。

### 令人困惑的 Class

使用 `Class` ，是使用和学习 `React` 的一大障碍。要求使用者理解 `class` 的用法（例如要理解 `this` ，处理事件绑定，使用一些提案中的语法），而且需要学会分辨，什么时候该用 `function component`，什么时候该用 `class component`。

`class component` 也可能会导致 [Prepack](https://prepack.io/) 一些优化失效。

还有就是 `class` 对一些开发工具的影响，例如： don’t minify very well(这个应该是 es6 的通病)，同时也会导致 hot reloading 出问题。

Hooks 可以让你不使用 `class` ，也可以用上 React 的一些功能。而 React 本身也是更倾向于 functions，使用 Hooks 可以更好的拥抱 functions。


> [Introducing Hooks](https://reactjs.org/docs/hooks-intro.html)

