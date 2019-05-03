---
title: "HTML5 图片上传解决方案"
issue: 37
date: 2018-11-29 14:18:59
categories: "前端"
tags: ["HTML5", "前端", "图片上传", "图片压缩", "图片预览"]
---

## 前言

前端做图片上传时，经常会遇到图片压缩、图片预览等需求。而这个过程中，会遇到一个个的坑。下面就来看一看 HTML5 实现图片上传的整个过程。

<!-- more -->

## 基本结构

图片上传是使用 input 标签来选择图片的：

```html
<input type="file" accept="image/*">
```

这里可能遇到一个坑：

可能会遇到响应迟钝，文件选择框过好几秒才弹出。[具体的原因可以查看这里](https://zhuanlan.zhihu.com/p/27946188)。

解决的方法是将 * 通配符改成指定的 MIME 类型。例如

```html
<input type="file" accept="image/gif,image/jpeg,image/jpg,image/png">
```



## 获取图片文件

通过监听 input 的 `change` 事件，获取 `FileList`类数组对象（event.target.files）。`FileList` 对象的成员就是 `File`对象，包含的属性如图：

![](/images/h5-img-upload/h5-img-upload1.jpg)



## FileReader

要对图片进行压缩，首先要获取图片内容。

这里需要使用 `FileReader`的`readAsDataURL(Blob|File)` 来读取图片内容。`readAsDataURL`方法返回 data URL，将文件进行 base64 编码。示例如下：

```javascript
let fr = new FileReader();
// 读取成功回调
fr.onload = e => {
  // e.target.result 就是图片的 base64 地址，可以直接用于图片的 src
  img.src = e.target.result;
}
// 失败回调
fr.onerror = e => {
  // error handle
}
// 读取图片
fr.readAsDataURL(file);
```

> 方法参考：[FileReader](https://developer.mozilla.org/zh-CN/docs/Web/API/FileReader)



## 图片压缩

前端进行图片压缩，不但节省流量，而且加速上传速度，提高用户体验。

上一步读取了图片，就可以对图片进行操作了。前端实现图片压缩，原理很简单：

1. 缩小图片，大图片转成小图片
2. 降低图片质量

第一点是通过 `canvas` 的 `drawImage()`方法来实现，第二点在后面会提到。

```js
void ctx.drawImage(image, dx, dy, dWidth, dHeight)
```

是在 canvas 上绘制图像，我们只需要把原图，在 canvas 上绘制成更小的图片，就实现了压缩，就是这么简单。

所以关键就是怎么来设置 `dWidth` 和`dHeight`。

一般的做法是限制图片的最大长度和宽度，超过则等比例缩放。例如：

```javascript
// width height 图片长宽
// maxWidth maxHeight 限制的图片最大长宽
let scale = width / height;

if (scale >= maxWidth / maxHeight) {
  if (width > maxWidth) {
    height = maxWidth / scale;
    width = maxWidth;
  }
} else if (height > maxHeight) {
  width = maxHeight * scale;
  height = maxHeight;
}
// 这里的 image 就是上一步得到的图片内容
ctx.drawImage(image, 0, 0, width, height);
```

>  方法参考： [CanvasRenderingContext2D.drawImage()](https://developer.mozilla.org/en-US/docs/Web/API/CanvasRenderingContext2D/drawImage)



## 图片输出

上一步在 canvas 绘画了图片，接下来就需要把 canvas 画布转化成 img 图像。

`canvas`提供了两个转图片的方法：

- [HTMLCanvasElement.toDataURL()](https://developer.mozilla.org/zh-CN/docs/Web/API/HTMLCanvasElement/toDataURL)：图片转换成base64格式
- [HTMLCanvasElement.toBlob()](https://developer.mozilla.org/zh-CN/docs/Web/API/HTMLCanvasElement/toBlob)：图片转换成Blob文件

### toDataURL()

```javascript
canvas.toDataURL(type, encoderOptions);
```

属于同步方法，返回 base64 格式的图片。

第一个参数 `type`是图片格式；

第二个参数 `encoderOptions` 就是用于之前提到的，控制图片质量，达到压缩图片的效果。

> 在指定图片格式为 `image/jpeg 或` `image/webp的情况下，可以从 0 到 1 的区间内选择图片的质量`。如果超出取值范围，将会使用默认值 `0.92`。

### toBlob()

```javascript
void canvas.toBlob(callback, type, encoderOptions);
```

属于异步方法，所以有个`callback` 参数。

`type` 参数指定图片格式；

`encoderOptions`参数指定图片质量，用于压缩图片

> 值在0与1之间，当请求图片格式为`image/jpeg`或者`image/webp`时用来指定图片展示质量。

> 关于 Blob：
>
> [`Blob`](https://developer.mozilla.org/zh-CN/docs/Web/API/Blob)对象表示一个不可变、原始数据的类文件对象。Blob 表示的不一定是JavaScript原生格式的数据。[`File`](https://developer.mozilla.org/zh-CN/docs/Web/API/File) 接口基于`Blob`，继承了 blob 的功能并将其扩展使其支持用户系统上的文件。
>
> [JavaScript 中 Blob 对象](https://juejin.im/entry/5937c98eac502e0068cf31ae): 这篇文章介绍了 Blob，里面也提到了大文件分割上传的实现。



一般来说，对比 Blob 文件和 base64 ，有下面几点优点：

- 二进制文件，对后端更友好
- base64 字符串一般都非常长，会有性能等问题

所以选择转化成 Blob 文件进行上传更好。把 base64 或者 Blob 文件加入 `FormData` 里就可以实现上传了。



## 图片预览

一般图片上传还会要求实现图片上传进度、图片预览功能。

关于图片预览的实现，可以通过下面的方法，来获取图片链接，做为本地预览：

- base64 可以作为图片链接，`FileReader.readAsDataURL(Blob|File)`方法可以得到 base64

- `URL.createObjectURL(Blob|File)`返回的 URL 可以作为图片的链接


> 详情参考：
>
> [FileReader.readAsDataURL()](https://developer.mozilla.org/zh-CN/docs/Web/API/FileReader/readAsDataURL)
>
> [URL.createObjectURL()](https://developer.mozilla.org/zh-CN/docs/Web/API/URL/createObjectURL)



## 手机照片旋转问题

把在 iPhone 上拍出来的照片，通过上面的方式进行上传，你会发现图片方向和你预料的不同。

### orientation

使用 iPhone 拍照片，会根据你拍照时手机的方向，照片会有不同的方向。这个方向可以通过图片的 `orientation`参数来确定。

| 旋转角度  | 参数值 | 手机方向                       |
| --------- | ------ | ------------------------------ |
| 0°        | 1      | home 键在右方的横屏拍摄方式    |
| 逆时针90° | 6      | home键在下方(正常拿手机的方向) |
| 顺时针90° | 8      | home键在上方                   |
| 180°      | 3      | home键在左侧                   |


可以通过 [exif-js](https://github.com/exif-js/exif-js) 来获取图片的 `orientation`：

```javascript
import EXIF from 'exif-js';

// file 是上面提到的 File 文件
EXIF.getData(file, function() {
	var orientation = EXIF.getTag(this, 'Orientation');
});
```

> 详情参考：[如何处理iOS中照片的方向](http://feihu.me/blog/2015/how-to-handle-image-orientation-on-iOS/)


### 校正方向

要校正图片的方向，只需要根据 `orientation` 参数，把图片的方向旋转会正常即可。旋转需要用到 canvas 的 [`rotate()`](https://developer.mozilla.org/zh-CN/docs/Web/API/CanvasRenderingContext2D/rotate)方法。

```javascript
void ctx.rotate(angle);
```

参数 angle 是顺时针旋转的弧度，旋转中心点是 canvas 的起始点。

角度值换算弧度的公式： `angle = degree * Math.PI / 180`

以 `orientation`等于 6 时为例，也就是图片逆时针旋转了 90°，要把图片校正方向，就要画布顺时针旋转 90° : `rotate((90 * Math.PI) / 180)`

![](/images/h5-img-upload/h5-img-upload2.jpg)

画布旋转之后，`drawImage()`根据画布的位置进行调整，如上图所示:

旋转之前：`drawImage(image, 0, 0, x, y)`

旋转之后，原有的画布不变，坐标跟着旋转，图片转到可视范围之外，所以：

- 需要把图片移到可视范围里
- 调整画布大小 

```javascript
// other code...
case 6:
	// 旋转角度
	degree = 90;
	// 调整画布大小
	canvas.width = imgHeight;
	canvas.height = imgWidth;
	// 修改绘画位置
	imgHeight = - imgHeight;
	break;
// other code ...
// canvas 旋转
ctx.rotate((degree * Math.PI)/180);
// 绘制图片
ctx.drawImage(image, 0, 0, imgWidth, imgHeight);
```

其他的 `orientation` 也是类似的原理。[查看示例代码](https://github.com/hhking/fe-demo/blob/054ec906907988aae919deda5e3369c7a1cb84e9/h5ImgCompress/h5ImgCompress.js#L52)



## 总结

图片压缩上传的过程，总结起来就是：图片 → 压缩 → 图片。

这个过程中，核心点是：

- FileReader API 使用

- Canvas 实现图片压缩、绘制和方向校正


这里主要总结了使用 HTML5 API 实现图片上传的过程，在实际的使用还要根据具体的使用场景，考虑兼容问题，选择合适的解决方案。

最后，查看完整的示例代码：[h5ImgCompress](https://github.com/hhking/fe-demo/tree/054ec906907988aae919deda5e3369c7a1cb84e9/h5ImgCompress)


