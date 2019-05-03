---
title: 移动端重构笔记
date: 2017-03-04 16:24:27
categories: 
    - "前端"
    - "CSS"
tags: [移动端, 重构]
---


####   1. box-sizing 设置

```
box-sizing: content-box|border-box
```

<!--more-->

*   **content-box**
    默认值，标准和模型。width与height只包括内容的宽和高，不包括边框(border)，内边距(padding)，外边距(margin)。也就是说，内边距、边框和外边距都在盒子的外部。

    尺寸计算公式：
    width = 内容的宽度
    height = 内容的高度
    *宽度和高度都不包含内容的边框 （border）和内边距（padding）*

*   **border-box**
    width和height包括了内边距(padding)和边框(border)，不包括外边距(margin)。这时候外边距和边框是包含在盒子中。

    尺寸计算公式：
    width = border + padding + 内容的宽度
    height = border + padding + 内容的高度

    所以如果将一个元素width设置100%，同时又设置边框或者左右padding时，元素的尺寸会大于100%，也会出现水平方向的滚动条。这时候可以设置border-box就可以解决这个问题。

####   2. 字体设置

```
body {
    font-family: -apple-system, BlinkMacSystemFont, "PingFang SC","Helvetica Neue",STHeiti,"Microsoft Yahei",Tahoma,Simsun,sans-serif;

}
```
>详情参考[font-family](https://github.com/AlloyTeam/Mars/blob/master/solutions/font-family.md)


####    3. -webkit-overflow-scrolling
```
-webkit-overflow-scrolling: touch;/* 当手指从触摸屏上移开，会保持一段时间的滚动 */
-webkit-overflow-scrolling: auto;/* 当手指从触摸屏上移开，滚动会立即停止 */
```

一般为了更好的体验，都会将该属性设置为touch
*该属性仅支持：移动版 Safari  iOS 5.0+*


####    4. -webkit-tap-highlight-color
```
-webkit-tap-highlight-color: transparent;
```
去除a标签点击时的高亮效果（对于ios点击元素的时候，就会出现一个半透明的灰色背景；对于android则出现红色的边框）


####    5. -webkit-text-size-adjust
```
-webkit-text-size-adjust: 100%;
text-size-adjust: 100%;
```
浏览器纵向 (Portrate mode) 和橫向 (Landscape mode) 模式皆有自动调整字体大小的功能。控制它的就是 CSS 中的 -webkit-text-size-adjust


####    6. -webkit-appearance
```
-webkit-appearance:none;
```

iOS设备上，使用input时会有内阴影，这是因为-webkit-appearance默认样式的原因，可以覆盖该属性来取出input的内阴影。


####    7. postion: sticky
```
position: -webkit-sticky
position: sticky;
```
粘性定位元素，在iOS上做粘性导航（例如页面滚动某个位置时，将导航固定在顶部）的时候效果很好。安卓上不支持该属性，只能通过scroll事件配合fixed定位要模拟实现。

postion: sticky元素先按照普通文档流定位，然后相对于该元素在流中的 flow root（BFC）和 containing block（最近的块级祖先元素）定位。在所有情况下（即便被定位元素为 table 时），该元素定位均不对后续元素造成影响。当元素 B 被粘性定位时，后续元素的位置仍按照 B 未定位时的位置来确定。position: sticky 对 table 元素的效果与 position: relative 相同。


####    8. meta
```
<!--忽略页面中的数字识别为电话号码、email识别-->
<meta name="format-detection" content="telphone=no, email=no" />

<!-- 启用360浏览器的极速模式(webkit) -->
<meta name="renderer" content="webkit">

<!-- 优先使用 IE 最新版本和 Chrome -->
<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1">

<!-- 针对手持设备优化，主要是针对一些老的不识别viewport的浏览器，比如黑莓 -->
<meta name="HandheldFriendly" content="true">

<!-- 微软的老式浏览器 -->
<meta name="MobileOptimized" content="320">

<!-- uc强制竖屏 -->
<meta name="screen-orientation" content="portrait">

<!-- QQ强制竖屏 -->
<meta name="x5-orientation" content="portrait">

<!-- UC强制全屏 -->
<meta name="full-screen" content="yes">

<!-- QQ强制全屏 -->
<meta name="x5-fullscreen" content="true">

<!-- UC应用模式 -->
<meta name="browsermode" content="application">

<!-- QQ应用模式 -->
<meta name="x5-page-mode" content="app">

<!-- windows phone 点击无高光 -->
<meta name="msapplication-tap-highlight" content="no">
```

####    9.viewport
```
<meta name="viewport" content="initial-scale=1.0,width=device-width,user-scalable=0,maximum-scale=1.0"/>
```
>参考
>[ppk 谈 viewport其1](http://www.quirksmode.org/mobile/viewports.html)
>[ppk 谈 viewport其2](http://www.quirksmode.org/mobile/viewports2.html)
>[ppk 谈 viewport其3](http://www.quirksmode.org/mobile/metaviewport/)