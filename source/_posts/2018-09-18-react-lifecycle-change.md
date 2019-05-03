---
title: "重新认识 React 生命周期"
issue: 31
date: 2018-09-18 19:48:51
categories: 
  - 前端
  - React
tags: ["React", "生命周期"]
---

# 前言
React 从 v16 开始，像是跨入了新的时代，性能和新的 API 都令人瞩目。重新认识 React，从重新认识生命周期开始。

为了更好的支持异步渲染（Async Rendering），解决一些生命周期滥用可能导致的问题，React 从 V16.3 开始，对生命周期进行渐进式调整，同时在官方文档也提供了使用的最佳实践。

这里我们将简要对比 React 新旧生命周期，重新认识一下 React 生命周期。

<!-- more -->

# 新的生命周期
先看看两张经典的生命周期的示意图
![旧的生命周期](https://ws3.sinaimg.cn/large/006tNbRwgy1fvccxme0cjj31kw1ns42n.jpg)
<center>旧的生命周期</center>
<br>

![新的生命周期](https://ws1.sinaimg.cn/large/006tNbRwgy1fvcdp2zaldj31kw0wlgon.jpg)
<center>新的生命周期</center>
<br>

React 16.3 新增的生命周期方法
1.  getDerivedStateFromProps()
2.  getSnapshotBeforeUpdate()

逐渐废弃的生命周期方法：
1.  componentWillMount()
2.  componentWillReceiveProps()
3.  componentWillUpdate()

> 虽然废弃了这三个生命周期方法，但是为了向下兼容，将会做渐进式调整。（详情见[#12028](https://github.com/facebook/react/pull/12028)）
> V16.3 并未删除这三个生命周期，同时还为它们新增以 UNSAFE_ 前缀为别名的三个函数 `UNSAFE_componentWillMount()`、`UNSAFE_componentWillReceiveProps()`、`UNSAFE_componentWillUpdate()`。
> 在 16.4 版本给出警告将会弃用 `componentWillMount()`、`componentWillReceiveProps()`、`componentWillUpdate()` 三个函数
> 然后在 17 版本将会删除 `componentWillMount()`、`componentWillReceiveProps()`、`componentWillUpdate()` 这三个函数，会保留使用 `UNSAFE_componentWillMount()`、`UNSAFE_componentWillReceiveProps()`、`UNSAFE_componentWillUpdate()`


一般将生命周期分成三个阶段：
1.  创建阶段（Mounting）
2.  更新阶段（Updating）
3.  卸载阶段（Unmounting）

从 React v16 开始，还对生命周期加入了错误处理（Error Handling）。

下面分析一下生命周期的各个阶段。

## 创建阶段 Mounting
组件实例创建并插入 DOM 时，按顺序调用以下方法：
- constructor()
- static getDerivedStateFromProps()
- ~~componentWillMount()/UNSAFE_componentWillMount()~~（being deprecated）
- render()
- componentDidMount()

> 有定义 `getDerivedStateFromProps` 时，会忽略 `componentWillMount()/UNSAFE_componentWillMount()`
（[详情查看源码](https://github.com/facebook/react/blob/master/packages/react-dom/src/server/ReactPartialRenderer.js)）

### constructor()
```jsx
constructor(props)
```
构造函数通常用于：
* 使用 `this.state` 来初始化 `state`
* 给事件处理函数绑定 `this`

> 注意：ES6 子类的构造函数必须执行一次 super()。React 如果构造函数中要使用 this.props，必须先执行 super(props)。

### static getDerivedStateFromProps()
```jsx
static getDerivedStateFromProps(nextProps, prevState)
```
当创建时、接收新的 props 时、setState 时、forceUpdate 时会执行这个方法。

> 注意：v16.3 setState 时、forceUpdate 时不会执行这个方法，v16.4 修复了这个问题。

这是一个 [静态方法](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Classes/static)，参数 `nextProps` 是新接收的 `props`，`prevState` 是当前的 `state`。返回值（对象）将用于更新 `state`，如果不需要更新则需要返回 `null`。

下面是官方文档给出的例子
```jsx
class ExampleComponent extends React.Component {
  // Initialize state in constructor,
  // Or with a property initializer.
  state = {
    isScrollingDown: false,
    lastRow: null,
  };

  static getDerivedStateFromProps(props, state) {
    if (props.currentRow !== state.lastRow) {
      return {
        isScrollingDown: props.currentRow > state.lastRow,
        lastRow: props.currentRow,
      };
    }

    // Return null to indicate no change to state.
    return null;
  }
}
```

这个方法的常用作用也很明显了：父组件传入新的 `props` 时，用来和当前的 `state` 对比，判断是否需要更新 `state`。以前一般使用 `componentWillReceiveProps` 做这个操作。

这个方法在建议尽量少用，只在必要的场景中使用，一般使用场景如下：
1. 无条件的根据 `props` 更新 `state`
2. 当 `props` 和 `state` 的不匹配情况更新 `state`

详情可以参考官方文档的最佳实践 [You Probably Don't Need Derived State](http://react.css88.com/blog/2018/06/07/you-probably-dont-need-derived-state.html#what-about-memoization)

### componentWillMount()/UNSAFE_componentWillMount()（弃用）
```jsx
UNSAFE_componentWillMount()
```
这个方法已经不推荐使用。因为在未来异步渲染机制下，该方法可能会多次调用。它所行使的功能也可以由 `componentDidMount()` 和 `constructor()` 代替：

- 之前有些人会把异步请求放在这个生命周期，其实大部分情况下都推荐把异步数据请求放在 `componentDidMount()` 中。
- 在服务端渲染时，通常使用 `componentWillMount()` 获取必要的同步数据，但是可以使用 `constructor()` 代替它。

**可以使用 setState，不会触发 re-render**

### render
```jsx
render()
```
每个类组件中，`render()` 唯一必须的方法。

`render()` 正如其名，作为渲染用，可以返回下面几种类型：
* React 元素（React elements）
* 数组（Arrays）
* 片段（fragments）
* 插槽（Portals）
* 字符串或数字（String and numbers）
* 布尔值或 null（Booleans or null）

> 注意：
> Arrays 和 String 是 v16.0.0 新增。
> fragments 是 v16.2.0 新增。
> Portals 是 V16.0.0 新增。

里面不应该包含副作用，应该作为纯函数。

**不能使用 setState。**

### componentDidMount()
```jsx
componentDidMount()
```
组件完成装载（已经插入 DOM 树）时，触发该方法。这个阶段已经获取到真实的 DOM。

一般用于下面的场景：
* 异步请求 ajax
* 添加事件绑定（注意在 `componentWillUnmount` 中取消，以免造成内存泄漏）

**可以使用 setState，触发re-render，影响性能。**

## 更新阶段 Updating
- ~~componentWillReceiveProps()/UNSAFE_componentWillReceiveProps()~~（being deprecated）
- static getDerivedStateFromProps()
- shouldComponentUpdate()
- ~~componentWillUpdate()/UNSAFE_componentWillUpdate()~~（being deprecated）
- render()
- getSnapshotBeforeUpdate()
- componentDidUpdate()

> 有 `getDerivedStateFromProps` 或者 `getSnapshotBeforeUpdate` 时，`componentWillReceiveProps()/UNSAFE_componentWillReceiveProps()` 和 `componentWillUpdate()/UNSAFE_componentWillUpdate()` 不会执行 （[详情查看源码](https://github.com/facebook/react/blob/master/packages/react-reconciler/src/ReactFiberClassComponent.js)）

### componentWillReceiveProps()/UNSAFE_componentWillReceiveProps()（弃用）
```jsx
UNSAFE_componentWillReceiveProps(nextProps)
```
这个方法在接收新的 props 时触发，即使 props 没有变化也会触发。

一般用这个方法来判断 props 的前后变化来更新 `state`，如下面的例子：

```jsx
class ExampleComponent extends React.Component {
  state = {
    isScrollingDown: false,
  };

  componentWillReceiveProps(nextProps) {
    if (this.props.currentRow !== nextProps.currentRow) {
      this.setState({
        isScrollingDown:
          nextProps.currentRow > this.props.currentRow,
      });
    }
  }
}
```

这个方法将被弃用，推荐使用 `getDerivedStateFromProps` 代替。

**可以使用 setState**

### static getDerivedStateFromProps()
同 Mounting 时所述一致。

### shouldComponentUpdate()
在接收新的 `props` 或新的 `state` 时，在渲染前会触发该方法。

该方法通过返回 `true` 或者 `false` 来确定是否需要触发新的渲染。返回  `false`， 则不会触发后续的 `UNSAFE_componentWillUpdate()`、`render()` 和 `componentDidUpdate()`（但是 `state` 变化还是可能引起子组件重新渲染）。 

所以通常通过这个方法对 `props` 和 `state` 做比较，从而避免一些不必要的渲染。

> PureComponent 的原理就是对 `props` 和 `state` 进行浅对比（shallow comparison），来判断是否触发渲染。

### componentWillUpdate()/UNSAFE_componentWillUpdate() （弃用）
```jsx
UNSAFE_componentWillUpdate(nextProps, nextState)
```
当接收到新的 props 或 state 时，在渲染前执行该方法。

在以后异步渲染时，可能会出现某些组件暂缓更新，导致 `componentWillUpdate` 和 `componentDidUpdate` 之间的时间变长，这个过程中可能发生一些变化，比如用户行为导致 DOM 发生了新的变化，这时在 `componentWillUpdate` 获取的信息可能就不可靠了。

**不能使用 setState**

### render()
同 Mounting 时所述一致。

### getSnapshotBeforeUpdate()
```jsx
getSnapShotBeforeUpdate(prevProps, prevState)
```
这个方法在 `render()` 之后，`componentDidUpdate()` 之前调用。

两个参数 `prevProps` 表示更新前的 `props`，`prevState` 表示更新前的 `state`。

返回值称为一个快照（snapshot），如果不需要 snapshot，则必须显示的返回 `null` —— 因为返回值将作为 `componentDidUpdate()` 的第三个参数使用。所以这个函数必须要配合 `componentDidUpdate()` 一起使用。

这个函数的作用是在真实 DOM 更新（`componentDidUpdate`）前，获取一些需要的信息（类似快照功能），然后作为参数传给 `componentDidUpdate`。例如：在 `getSnapShotBeforeUpdate` 中获取滚动位置，然后作为参数传给 `componentDidUpdate`，就可以直接在渲染真实的 DOM 时就滚动到需要的位置。

下面是官方文档给出的例子：
```jsx
class ScrollingList extends React.Component {
  constructor(props) {
    super(props);
    this.listRef = React.createRef();
  }

  getSnapshotBeforeUpdate(prevProps, prevState) {
    // Are we adding new items to the list?
    // Capture the scroll position so we can adjust scroll later.
    if (prevProps.list.length < this.props.list.length) {
      const list = this.listRef.current;
      return list.scrollHeight - list.scrollTop;
    }
    return null;
  }

  componentDidUpdate(prevProps, prevState, snapshot) {
    // If we have a snapshot value, we've just added new items.
    // Adjust scroll so these new items don't push the old ones out of view.
    // (snapshot here is the value returned from getSnapshotBeforeUpdate)
    if (snapshot !== null) {
      const list = this.listRef.current;
      list.scrollTop = list.scrollHeight - snapshot;
    }
  }

  render() {
    return (
      <div ref={this.listRef}>{/* ...contents... */}</div>
    );
  }
}
```

### componentDidUpdate()
```jsx
componentDidUpdate(prevProps, prevState, snapshot)
```
这个方法是在更新完成之后调用，第三个参数 `snapshot` 就是 `getSnapshotBeforeUpdate` 的返回值。

正如前面所说，有 `getSnapshotBeforeUpdate` 时，必须要有 `componentDidUpdate`。所以这个方法的一个应用场景就是上面看到的例子，配合 `getSnapshotBeforeUpdate` 使用。

**可以使用 setState，会触发 re-render，所以要注意判断，避免导致死循环。**

## 卸载阶段 Unmounting
- componentWillUnmount()

### componentWillUnmount
```jsx
componentWillUnmount()
```
在组件卸载或者销毁前调用。这个方法主要用来做一些清理工作，例如：
- 取消定时器
- 取消事件绑定
- 取消网络请求

**不能使用 setState**

## 错误处理 Error Handling
- componentDidCatch()

### componentDidCatch()
```jsx
componentDidCatch(err, info)
```

任何子组件在渲染期间，生命周期方法中或者构造函数 constructor 发生错误时调用。

错误边界不会捕获下面的错误：
- 事件处理 (Event handlers) （因为事件处理不发生在 React 渲染时，报错不影响渲染）
- 异步代码 (Asynchronous code) (e.g. setTimeout or requestAnimationFrame callbacks)
- 服务端渲染 (Server side rendering)
- 错误边界本身(而不是子组件)抛出的错误

# 总结

React 生命周期可以查看 [生命周期图](http://projects.wojtekmaj.pl/react-lifecycle-methods-diagram/)

虽然 React 有做向下兼容，但是推荐尽量避免使用废弃的生命周期，而是拥抱未来，用新的生命周期替换它们。

如果你不想升级 React，但是想用新的生命周期方法，也是可以的。使用 [react-lifecycles-compat](https://github.com/reactjs/react-lifecycles-compat) polyfill，可以为低版本的 React（0.14.9+）提供新的生命周期方法。

> 参考：
[React.Component](https://reactjs.org/docs/react-component.html)
[Update on Async Rendering](http://react.css88.com/blog/2018/03/27/update-on-async-rendering.html)

