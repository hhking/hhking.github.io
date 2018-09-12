---
title: "[译] 使用 React 一年后，我学到的最重要经验"
issue: -1
date: 2018-09-12 20:27:23
categories: [翻译]
tags: ["前端", "JavaScript", "React", "经验分享"]
---

> 原文：[The most important lessons I’ve learned after a year of working with
React](https://medium.freecodecamp.org/mindset-lessons-from-a-year-with-react-1de862421981)
> 作者：Tomas Eglinskas

![images](https://cdn-images-1.medium.com/max/2000/1*TheYckj9udF4qLjoJW8sjg.png)
<center>No, I didn’t wrote that, but I know it got your attention 🔪</center>

<br>

开始学习一项新的技术时候令人很苦恼。你经常发现自己处于教程和文章的海洋里，还伴随着无数的个人观点。并且每个人都声称他们找到了“正确而完美的方式”。

<!-- more -->

这让我们需要去辨别：我们选择的教程是否会浪费时间。

在潜入这片海洋之前，我们必须要理解该技术的基本概念。然后我们需要建立基于技术的思维模式。如果我们开始学习 React，我们首先要以 React 的方式去思考。后面我们才可以开始将各种思维模式融为一体。

在这篇文章，我将从个人使用 React 的经历来介绍从中学到的一些关于这种思维的经验。我们将回顾工作时间和做个人项目的夜晚，甚至我在本地 JavaScript 活动中的演讲。

我们开始吧！


## React 在不断发展，你需要与时俱进

如果你记得 16.3.0 版本的首次公告，你会想起当时大家是多么的激动。

下面是我们看到的一些变化和提升：

- Official Context API
- createRef API
- forwardRef API
- StrictMode
- Component Lifecycle Changes

React 的核心团队和所有的贡献者正在做着伟大的工作 —— 努力改进我们所喜爱的技术。在 16.4.0 版本我们看到了 [Pointer Events](https://reactjs.org/blog/2018/05/23/react-v-16-4.html)。

毫无疑问更多的变化将会来临，这只是时间问题：异步渲染 (Async Rendering)、缓存 (Caching) 、version 17.0.0 以及其他未知的。

所以，如果你想成为佼佼者，你必须紧跟着社区里变化的脚步。

**``了解事物的工作原理，以及被开发出来的原因。了解正在解决的问题，以及开发是如何变得越来越简单。这会让你受益匪浅。``**


## 不要害怕把你的代码拆分成更小的块

React 是基于组件的。所以你应该利用这个概念，而不是害怕把大的模块拆分更小的模块。

有时候，一个简单的组件可能只有 4-5 行代码，在某些情况下，这完全没有问题。

这样做，可以让新人加入时，不需要花几天的时间去理解这些代码是如何运行的。

```jsx
// isn't this easy to understand?
return (
  [
   <ChangeButton
    onClick={this.changeUserApprovalStatus}
    text="Let’s switch it!"
   />,
   <UserInformation status={status}/> 
  ]
);
```

你不必让组件都包含复杂的逻辑。它们可以只当视觉组件。如果这样可以提高代码的可读性和方便测试，并减少代码的“坏味道”，那么对团队的每个人来说都是个伟大的胜利。

```jsx
import ErrorMessage from './ErrorMessage';
const NotFound = () => (
  <ErrorMessage
    title="Oops! Page not found."
    message="The page you are looking for does not exist!"
    className="test_404-page"
  />
);
```

上面这个例子，属性都是固定的。所以我们可以有个纯组件控制网站的错误信息 `Not Found`，仅此而已。

并且，如果你不喜欢 CSS 的 class 选择器作为 class 名到处都是，我会推荐使用 styled components。这样可以提高可读性。

```jsx
const Number = styled.h1`
  font-size: 36px;
  line-height: 40px;
  margin-right: 5px;
  padding: 0px;
`;
//..
<Container>
  <Number>{skipRatePre}</Number>
  <InfoName>Skip Rate</InfoName>
</Container>
```

如果你担心创建太多组件是因为太多文件会污染目录，那么重新考虑如何架构你的代码。我一直在使用分形结构 ([fractal structrue](https://hackernoon.com/fractal-a-react-app-structure-for-infinite-scale-4dab943092af))，它非常棒。


## 不要局限于基础 —— 转向高级

有时你可能会认为你对某些东西理解不够，不能转向高级应用。但是通常你不必过多担心 —— 接受挑战并证明自己的担心是错的。

通过掌握高级内容并推动你自己，你可以理解更多基础知识以及如何将他们运用在更大的项目上。

这里有许多模式可以尝试：

- 复合组件（Compound Components）
- 高阶组件 （High Order Components）
- Render Props
- Smart/Dumb 组件 （Smart/Dumb Components）
- 等等 (尝试去分析)

去研究他们，你会知道为什么使用它们、在哪里使用它们。用起 React 你会感觉更加得心应手。

```jsx
// looks like magic?
// it's not that hard when you just try
render() {
  const children = React.Children.map(this.props.children,
   (child, index) => {
      return React.cloneElement(child, {
        onSelect: () => this.props.onTabSelect(index)
    });    
 });  
 return children;
}
```

同时，不要害怕在工作中使用新东西 —— 当然，在一定范围内。

有人可能会质疑，这很正常。你的任务就是用强有力的证据来捍卫你的工作和决定。

你的目标应该是解决现有的问题，让后续开发更简单，或者清理一些面条式代码。即使你的建议被拒绝，你的收获也会比保持沉默得到的更多。

## 不要过度复杂
这个听起来像是个相反的观点，但是有所不同。在生活中，各个地方，我们都需要保持平衡。我们不应该过度设计来炫耀，而是要务实，编写易于理解并实现其功能的代码。

如果你不需要 Redux，但是你想使用它，因为很多人都在不知道它真正用途的情况下使用它。你不要这样做。要有自己的主张，如果有人推倒你，不要害怕站起来。

有时候你可能会想，通过使用最新的技术并编写复杂的代码，你可以向世界宣称：“我不是初级，我是中级/高级开发者。看看我能做什么！”

老实说，这便是我开发者生涯初期的心态。但是随着时间的推移，你会明白，不为炫耀、“能实现”的代码更容易接受。

1. 你的同事可以接手你的项目，你不是唯一负责开发、修复、测试工作的人。
2. 团队可以不需要通过长时间的会议就知道其他人做的事情。几分钟讨论就足够了。
3. 当你同事外出度假两周时，你可以接手他们的工作。而且你不需要工作 8 小时，因为你 1 小时就可以搞定。

人们尊重让别人生活更轻松的人。因此如果你的目标是获得别人的尊敬、提升排名、提升自己，那么你应该为团队而不是为你自己编写代码。

你会成为大家最喜欢的团队成员。

## 重构，重构，再重构 —— 这是正常的。

你可能会几十次的改变想法，虽然项目经理改变得更频繁。有人会评论你的工作，你也会评论他。所以结果是，你将会很多次的修改你的代码。

但是别担心，这是个正常的学习过程。不犯错、代码不报错，我们就无法提升自己。

跌倒的次数越多，重新站起来就变得越容易。

但是这里有个提醒：你要保证去测试你现在的软件。冒烟测试、单元测试、集成测试、快照测试 —— 别不好意思去测试。

每个人都看到或者将会看到测试可以节约宝贵时间的场景。

如果你和很多人一样，都认为做这些是浪费时间，试着以不同的角度想一想。

1. 你不需要和你同事一起向他解释是如何工作的。
2. 你不需要和你同事一起向他解释为何会出现错误。
3. 你不需要帮你同事修 bug。
4. 你不需要修 3 周后才发现的 bug。
5. 你将有时间做你想做的事情。

这些都是有很多益处的。


## 如果你喜欢它，你会不断成长

在过去的一年里，我的目标是更好的使用 React。我想做一个关于它的演讲。我想其他人和我一样享受它。

我可以不停歇的整晚坐在那编程，观看各种演讲并享受每一分钟。

事实是，当你想要什么，你会发现，不知怎么的就会有人开始帮助你。在上个月，我为 200 人做了首次关于 React 的演讲。

在这过去的一年里，我变得更加强大，React 用得更加得心应手 —— 各种模式，范式和内部原理。我可以进行高级内容的讨论并向别人讲授我之前害怕接触的话题。

今天我依旧感到兴奋和享受，一如一年前的感受。

因此，我建议每个人都问问自己：“你是否喜欢你在做的事情？”

如果不喜欢，那就继续寻找你可以谈论几个小时、每晚学习并且使你开心的那个特别的事情。

因为我们必须找到最接近我们内心的东西。成功不能强迫，而是主动获取。

如果我可以回到一年前，那么在进行这个大的旅程之前，这些就是我想对自己说的。

Thank you for reading!


