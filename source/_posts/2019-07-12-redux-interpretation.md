---
title: 'Redux 源码解读'
subtitle: redux-interpretation
issue: 44
date: 2019-07-12 10:42:14
categories:
  - 前端
  - Redux
tags: ["Redux"]
---

> 本篇解读基于 Redux 版本 4.0.1。
> 完整的注释发在这个仓库 [redux-interpretation](https://github.com/hhking/redux-interpretation)

Redux 的源码很短，核心就是实现下面这些 api，也是我们使用的时候会遇到的。

```js
store: {
  dispatch,
  subscribe,
  getState,
  replaceReducer
},
bindActionCreators,
combineReducers,
applyMiddleware
```


## createStore
createStore 是生成 store 的函数，返回 store 对象，`dispatch`, `subscribe`, `getState`, `replaceReducer` 都是在这里实现的

> 还有个 observable，是提供给 观察/响应式 库的接口

```js
// createStore.js
function createStore(reducer, preloadedState, enhancer) {
  //...
  return {
    dispatch,
    subscribe,
    getState,
    replaceReducer,
    [$$observable]: observable
  }
}
```

## dispatch

`dispatch` 本质就是调用 `reducer` 得到新的 state，然后再循环执行监听 state 变化的回调函数

```js
// createStore.js
function dispatch(action) {
  // ...
  try {
    // 开始执行 reducer
    isDispatching = true
    // reducer 的参数是当前的 state 和指定的 action，返回值作为新的 state, 所以要保证 reducer 一定要有 state 返回
    currentState = currentReducer(currentState, action)
  } finally {
    // reducer 执行完成
    isDispatching = false
  }
  /**
   * 这里获取最新的回调函数数组, 然后循环逐个执行.
   * 这里让 currentListeners = nextListeners, 如果这时候出现新增或者取消订阅, 之前的 ensureCanMutateNextListeners 就起作用了,
   * 改动不会影响当前执行的数组, 下次执行 dispatch 才会拿到改过后的数组
   */
  const listeners = (currentListeners = nextListeners)
  for (let i = 0; i < listeners.length; i++) {
    const listener = listeners[i]
    listener()
  }

  return action
}
```

## subscribe
`subscribe` 就是添加监听 state 变化的回调函数，保存在一个数组中，在 `dispatch` 后会循环执行这个数组。返回值是一个取消监听的函数。

```js
// createStore.js
function subscribe(listener) {
  //...
  // 标记订阅状态，取消订阅时避免重复取消订阅的逻辑执行，造成的性能损耗
  let isSubscribed = true
  // 添加 listener 之前，确保不改动 currentListeners，而是 currentListeners 的复制出来的 nextListeners
  ensureCanMutateNextListeners()
  // 添加回调函数 listener 到 nextListeners
  nextListeners.push(listener)

  // 订阅的返回值是个函数，调用这个返回值来取消订阅（类似于 setTimeout 的返回值可以用来取消定时器）
  return function unsubscribe() {
    if (!isSubscribed) {
      return
    }
    // reducer 执行时不能取消订阅
    if (isDispatching) {
      throw new Error(
        'You may not unsubscribe from a store listener while the reducer is executing. ' +
          'See https://redux.js.org/api-reference/store#subscribe(listener) for more details.'
      )
    }
    // 标记为未订阅
    isSubscribed = false
    // 这里会再次确认 nextListeners 和 currentListeners 时，浅复制一份新的 nextListeners 出来
    ensureCanMutateNextListeners()
    // 找到需要取消订阅的 listener，通过 splice 从数组中删除，变化体现在 nextListeners 数组中
    const index = nextListeners.indexOf(listener)
    nextListeners.splice(index, 1)
  }
}
```

这里注意到一个函数 `ensureCanMutateNextListeners`，是干嘛用的呢？

```js
// createStore.js
function ensureCanMutateNextListeners() {
    if (nextListeners === currentListeners) {
      nextListeners = currentListeners.slice()
    }
  }
```

考虑下面这种场景：
`dispatch` 过程中，监听回调 listener 数组 `[ a, b, c ,d ]` 在循环执行，但是刚执行完 a，a 被取消监听了，这时候数组就会变成 `[ b, c ,d ]`，c 是数组的第二项了。原本要执行第二项的 b 就被跳过了，而去执行 c 去了。
这个函数的作用是为了保证在 `dispatch` 过程中，新增或者取消订阅不会影响到当前的 `dispatch`，避免类似这种场景下 bug 的产生。
浅复制一份 `currentListeners`，保证当前的 `dispatch` 的不变，新增或者取消的会在 `nextListeners` 中体现，也就是下次 dispatch 时。 (subscribe 的注释里也有说明)

## getState
这个简单粗暴，就是返回当前的 state

## replaceReducer
这个方法直接替换当前的 `reducer`，然后执行 `dispatch({ type: ActionTypes.REPLACE })` 这个内置的 `action`，根据新的 `reducer` 生成新的 `state`。

这个方法的使用场景：
- 代码分割按需加载
- 热替换

### bindActionCreators
这个方法就是提供一个简写的调用方式，给 ActionCreator 加个自动 `dispatch`

```js
// bindActionCreators.js 部分代码

// 这个方法的做用，其实就是一个简写的调用方法，方便使用
// 结果就是返回一个函数: `dispatch(actionCreator(xxx))`
function bindActionCreator(actionCreator, dispatch) {
  return function() {
    return dispatch(actionCreator.apply(this, arguments))
  }
}
```

### combineReducers
`combineReducers` 这个函数的作用是，把一个包含各个 reducer 函数的对象，合并成一个 reducer 函数。
这部分代码也不复杂，除去一些错误检查之类的，就是对 reducer 就行处理合并，执行返回的函数，才是执行真正的所有的 reducer 逻辑

```js
//combineReducers
export default function combineReducers(reducers) {
  // 获取 reducers 这个对象的建 keys 对象
  const reducerKeys = Object.keys(reducers)
  const finalReducers = {}
  for (let i = 0; i < reducerKeys.length; i++) {
    const key = reducerKeys[i]

    // 判断 key 对应的 reducer 是不是 `undefined`
    if (process.env.NODE_ENV !== 'production') {
      if (typeof reducers[key] === 'undefined') {
        warning(`No reducer provided for key "${key}"`)
      }
    }
    /**
     * 确保 reducer 是个函数，然后根据 key/value 存在新对象 finalReducers
     * 这个新对象，包含的是过滤 undefined 和 非函数 后的 reducer
     * 保存在另一个对象，可以再后续的修改中，不影响到原来的 reducers 这个对象
     */
    if (typeof reducers[key] === 'function') {
      finalReducers[key] = reducers[key]
    }
  }
  const finalReducerKeys = Object.keys(finalReducers)

  // This is used to make sure we don't warn about the same
  // keys multiple times.
  let unexpectedKeyCache
  if (process.env.NODE_ENV !== 'production') {
    unexpectedKeyCache = {}
  }

  let shapeAssertionError
  try {
    assertReducerShape(finalReducers)
  } catch (e) {
    shapeAssertionError = e
  }

  // 返回一个合并后的 reducer 函数, state 默认值为空对象
  return function combination(state = {}, action) {
    if (shapeAssertionError) {
      throw shapeAssertionError
    }

    if (process.env.NODE_ENV !== 'production') {
      const warningMessage = getUnexpectedStateShapeWarningMessage(
        state,
        finalReducers,
        action,
        unexpectedKeyCache
      )
      if (warningMessage) {
        warning(warningMessage)
      }
    }

    let hasChanged = false
    const nextState = {}
    // 循环执行 reducer，这部分写的很清晰
    for (let i = 0; i < finalReducerKeys.length; i++) {
      const key = finalReducerKeys[i]
      const reducer = finalReducers[key]
      const previousStateForKey = state[key]
      const nextStateForKey = reducer(previousStateForKey, action)
      // 这里验证是否会没有 state 返回
      if (typeof nextStateForKey === 'undefined') {
        const errorMessage = getUndefinedStateErrorMessage(key, action)
        throw new Error(errorMessage)
      }
      nextState[key] = nextStateForKey
      hasChanged = hasChanged || nextStateForKey !== previousStateForKey
    }
    // state 有改变返回下一个 state，否则返回原来的 state
    return hasChanged ? nextState : state
  }
}
```

## applyMiddleware
`applyMiddleware` 是一个特殊的 `enhancer`，执行 `applyMiddleware` 和 `enhancer`，都要返回和 `createStore` 一样的 api。
`applyMiddleware` 接收的参数是中间件数组，最终形成一个中间件洋葱模型。

```js
// applyMiddleware.js
export default function applyMiddleware(...middlewares) {
  return createStore => (...args) => {
    const store = createStore(...args)
    let dispatch = () => {
      throw new Error(
        'Dispatching while constructing your middleware is not allowed. ' +
          'Other middleware would not be applied to this dispatch.'
      )
    }

    const middlewareAPI = {
      getState: store.getState,
      dispatch: (...args) => dispatch(...args)
    }
    // middlewareAPI 作为参数执行一遍所有的中间件
    const chain = middlewares.map(middleware => middleware(middlewareAPI))
    // 根据 compose 生产的其实是类似 mid1(mid2(mid3(store.dispatch)))
    // 所以在数组最后的 middleware 其实是第一个执行的
    dispatch = compose(...chain)(store.dispatch)

    return {
      ...store,
      dispatch
    }
  }
}
```

这里要结合实际的中间件来理解，下面是 logger 中间件的示例代码:
- 可以看到中间件 logger 其实是一个函数，参数为 dispatch 和 getState，这个对应上面的 middlewareAPI
- middleware(middlewareAPI) 执行后得到的还是个函数，参数是 next，看上面的 compose, 这个 next 其实就是 store.dispatch，返回的是新的 dispatch， 假如是 newDispatch
- 根据上面的 compose，你会发现，这个 newDispatch 是作为中间件链的下一个 middleware 的参数值（就是 next）这样一环扣一环，得到一个最终的 dispatch
- 在实际调用最终的 dispatch 时，你会发现，middleware 的执行顺序又变成是从左往右了（因为最终返回的 dispatch 是第一个中间件的函数）
- 执行过程中，遇到 next(action)，这时候其实就是右边一个 middleware 的返回的 dispatch，控制权就转到这个 middleware 了，
- 这样执行到最后，控制权返回，再执行 next 后面的代码
- 最终就是形成了中间件的洋葱模型，看下面的示意图

```js
// logger 中间件的示例代码
const logger = ({ getState, dispatch }) => next => action => {
  console.log('dispatching', action)
  let result = next(action)
  console.log('next state', store.getState())
  return result
}
```
```js
// 洋葱模型示意图
+-------------------------------------------------------------+
|   mid21                                                     |
|         +---------------------------------------------+     |
|         | mid2    +-----------------------------+     |     |
|         |         | mid2   +-------------+      |     |     |
|         |         |        |             |      |     |     |
-> next() -> next() ->next() -> dispatch() ->    ->    ->    ->
|         |         |        |             |      |     |     |
|         |         |        +-------------+      |     |     |
|         |         +-----------------------------+     |     |
|         +---------------------------------------------+     |
+-------------------------------------------------------------+

```

从这个模型可以知道中间件的工作原理，就是在发送 dispatch 之前以及发送之后，可以做一些你想做的事。

比如这个 logger 中间件的执行顺序会是 打印 dispatching -> 等待 next 执行返回 -> 打印 next state

这里可以思考一下，为什么 logger 中间件要求放在最后面?

写的比较粗糙，详细的可以看这个仓库的注释 [redux-interpretation](https://github.com/hhking/redux-interpretation)

THE END!
