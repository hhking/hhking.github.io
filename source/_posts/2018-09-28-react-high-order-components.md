---
title: React 高阶组件其实很简单
issue: 32
date: 2018-09-28 19:23:34
categories: ["React"]
tags: ["React", "高阶组件", "High-Order Components", "前端"]
---

## 前言
高阶组件 High-Order Components，不属于 React 的 API，而是 React 的一种运用技巧，或者说设计模式。所以，不使用高阶组件，也是可以实现功能，但是掌握高阶组件，可以提高代码的灵活性和复用性，实现起来更加优雅。当然，学会 React 的高级运用，也可以让你更加深入的理解 React。

高阶组件，其实没有想象的那么复杂。

<!-- more -->

## 什么是高阶组件
**高阶组件是一个函数，接收一个组件，然后返回一个新的组件。**
```jsx
const EnhancedComponent = highOrderComponent(WrappedComponent);
```

要记住的是，虽然名称是**高阶组件**，但是高阶组件不是组件，而是**函数**！

既然是函数，那就可以有参数，有返回值。从上面可以看出，这个函数接收一个组件 `WrappedComponent` 作为参数 ，返回**加工过**的新组件 `EnhancedComponent`。其实高阶组件就是设计模式里的装饰者模式。

可以说，组件是把 props 转化成 UI，而高阶组件是把一个组件转化成另外一个组件。

下面是一个简单的高阶组件：
```jsx
import React, { Component } from 'react';

export default (WrappedComponent) => {
  return class EnhancedComponent extends Component {
    // do something
    render() {
      return <WrappedComponent />;
    }
  }
}
```

从上面的代码可以看出，我们可以对传入的原始组件 `WrappedComponent` 做一些你想要的操作（比如操作 props，提取 state，给原始组件包裹其他元素等），从而**加工**出你想要的组件 `EnhancedComponent` 。把通用的逻辑放在高阶组件中，对组件实现一致的处理，从而实现代码的复用。


## 使用高阶组件
高阶组件的一个应用场景，就是在表单中的使用。

React 中 [受控组件](https://reactjs.org/docs/forms.html)，是通过 `state` 来控制用户的输入行为，所以我们需要通过监听 `onChange` 来更新 `state`，例如：
```jsx
import React, { Component } from 'react';

class Input extends Component {
  constructor(props) {
    super(props);

    this.state = {
      value: '',
    }
  }
  
  handleChange = (e) => {
    this.setState({
      value: e.target.value,
    });
  }
  
  render() {
    return (
      <input type="text" value={this.state.value} onChange={this.handleChange} />
    );
  }
}

export default Input;
```

通常，我们还需要对表单元素进行验证，这时可能需要在 `handleChange` 中添加验证的逻辑。如果是一个表单元素，这样写没什么问题，但是当表单元素越来越多，还是这样一个一个元素的添加逻辑的话，是一种什么体验？如果产品再改一下需求，那你就只能含泪加班了！

这时候，高阶组件的作用就可以体现出来了。只需要把所有表单元素通用的逻辑放在高阶组件中。把输入框需要的 `value` 和 `onChange` 提取到高阶组件，再通过 `props` 传给原始的组件：

```jsx
import React, { Component } from 'react';

export default (WrappedComponent) => {
  return class InputHOC extends Component {
    constructor(props) {
      super(props);
      this.state = {
        value: '',
      }
    }

    handleChange = (e) => {
      this.setState({
        value: e.target.value,
      });
    }

    render() {
      const passProps = {
        value: this.state.value,
        onChange: this.handleChange,
      }
      return <WrappedComponent {...passProps} />;
    }
  }
}
```

然后表单元素里就不需要实现 `state` 和 `onChange` 的逻辑，只需要处理传入的 `props`, 并调用一下**高阶组件**，得到的就是带有我们需要的属性和功能的**新组件**：
```jsx
import React, { Component } from 'react';
import InputHOC from './InputHOC';

import './style.css';

class Input extends Component {
  render() {
    return (
      <input className="input" type="text" {...this.props} />
    )
  }
}

export default InputHOC(Input);
```

然后你只要拿新的组件去使用，就可以了。如果还有其他的表单元素，同样只需要调用高阶组件，就可以得到你需要的组件。这就是一个简单的高阶组件的运用，实现代码的复用。

从上面的例子可以看出，在高阶组件里，你可以操作 `props`、`state`，甚至修改 `render` 方法里的渲染内容。

高阶组件的模式和数据流实际如图：
![](/images/react-hoc/react-hoc1.jpg)

## 一些注意点
### 参数
既然高级组件是一个函数，那么这个函数也可以有多个参数，例如：
```jsx
export default (WrappedComponent, data) => {
  return class EnhancedComponent extends Component {
    // do something with data
    render() {
      return <WrappedComponent />;
    }
  }
}
```

### 命名
高阶组件的创建的容器组件的名称在  React Developer Tools 中看起来和普通组件一样，看不出是不是使用了高阶组件。
![](/images/react-hoc/react-hoc2.jpg)

为了方便调试，一般约定用容器组件类名包裹原始组件来命名容器组件：
```jsx
import React, { Component } from 'react';

const getDisplayName = (WrappedComponent) => {
  return WrappedComponent.displayName ||
    WrappedComponent.name ||
    'Component'
}

export default (WrappedComponent, validate) => {
  return class InputHOC extends Component {
    static displayName = `InputHOC(${getDisplayName(WrappedComponent)})`;
    constructor(props) {
      super(props);
      this.state = {
        value: '',
      }
    }

    handleChange = (e) => {
      console.log(e);
      this.setState({
        value: e.target.value,
      });
    }

    render() {
      const passProps = {
        value: this.state.value,
        onChange: this.handleChange,
      }
      return <WrappedComponent {...passProps} />;
    }
  }
}

```
结果如下，这样就可以直观的看出是使用了高阶组件：
![](/images/react-hoc/react-hoc3.jpg)


### 多层高阶组件
可以对一个组件，应用多个高阶组件，形成多层嵌套：
```jsx
Input = InputHOC(Input);
Input = InputHHOC(Input);
```
![](/images/react-hoc/react-hoc4.jpg)


## 总结
高阶组件是属于 React 高级运用，但是其实是一个很简单的概念，但是它非常实用。在实际的业务场景中，灵活合理的使用高阶组件，可以提高代码的复用性和灵活性。

对高阶组件，我们可以总结以下几点：
- 高阶组件是一个函数，而不是组件
- 组件是把 props 转化成 UI，高阶组件是把一个组件转化成另一个组件
- 高阶组件的作用是复用代码
- 高阶组件对应设计模式里的装饰者模式
