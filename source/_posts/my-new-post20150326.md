title: "jQuery实现输入框标签的自动添加和删除等操作"
date: 2015-03-26 12:51:44
categories: "关于前端"
tags: [jQuery,tags,前端]
---
**记录一下这两天写的。**

------
### 实现如下对待选标签的操作 ###

> * 点击待选标签列表中的标签，标签从原来的位置消失，出现在输入框中
> * 点击标签上的X图标或者按退格键删除已选的标签，被删除的标签会回到原来待选标签的位置
> * 输入框可以输入标签文字后按回车键、空格键或者输入框失去焦点时自动生成标签

<!--more-->

------
### 截图展示 ###
* 部分效果图1：
![效果图1](http://7xi86v.com1.z0.glb.clouddn.com/tags1.jpg)

* 部分效果图1：
![效果图2](http://7xi86v.com1.z0.glb.clouddn.com/tags2.jpg)

------
### 实现方案 ###
#### 界面方面 ####
> * 首先要注意到，看上去输入框中出现的标签，实际上并不是在输入框中，而是在input之前通过添加span（标签）来实现，也就是说添加的标签事实上是在input之外的；
> * 通过外围的div包住input和span，设置边框，去掉input原来的表框，便造成视觉上的input的边框，添加的标签也出现在这个边框里；

如下代码：
* html:
``` bash
<div class="label_in">
            <p>产品类别<b>*</b>:</p>
            <div class="area">
                <div class="add">
                    <input type="text" name="input" placeholder="输入标签..." />
                </div>
                <br class="clear" />
            </div>
        </div>
```
* css:
``` bash
.area{
    width: 960px;
    border: 1px solid #a09d9d;
}
.add {
    float: left;
    line-height: 28px;
    overflow: hidden;
    border: none;
}
input {
    float: left;
    height: 28px;
    margin: 5px 0;
    padding-left: 12px;
    line-height: 28px;
    font-size: 18px;
    border: none;
    outline: none;
}
.clear{
    clear: both;
}
```
#### jQuery实现功能方面 ####
> * 标签点击事件。对整个标签列表进行绑定点击事件，注意要判断点击到span时候执行，否则点到margin（空白处）会将整个父节点作为目标。点击标签时，先复制clone()点击的span，在插入insertBefore()到input之前，并添加X图标；然后将原来的hide()（理论上也可以删除）。这里的num是原来在span标签里的排序位置，即index值，作为input之前标签的id，用于后面删除时，定位要显示的span，这个样就可以将标签恢复到原来位置。

``` bash
//点击事件，点击标签选择，标签出现在输入框，原来位置隐藏
        $(".label_type").click(function (e) {
            var num = $(e.target).index();
            var a = $(e.target).attr('class');
            //判断点的不是空白地方（标签的父标签）
            if (a != "label_type") {
                $(e.target).clone().insertBefore($(".add input")).addClass("ad").attr('id', num).append("<b class='close'>ⓧ</b>");
                $(e.target).hide();
            }
        });
```
> * X图标点击事件。将点击的那个span删除，在通过id定位原来的位置，将其show()显示出来。

``` bash
//点击事件，点击X号时候删除标签，并在原来位置显示
        $(".add").click(function (e) {
            if ($(e.target).html() == "ⓧ") {
                var numid = $(e.target).closest("span").attr('id');
                $(e.target).closest("span").remove();
                $(".label_type span").eq(numid).show();
            }
        });
```

> * 退格键的keyCode==8，执行删除操作。获取input之前的那个元素，并将其删除，同时通过id恢复原来的标签。这里要注意输入框中为空是执行，当输入框中有内容时正常删除操作。
> * 回车、空格以及输入框失去焦点都执行同一个操作。这里调用autocomplete()函数执行操作。

``` bash
//按键事件
        $(document).keydown(function (e) {
            //获取输入框里的内容
            var content = $("input").val();
            //按下退格键时触发时间
            if (e.keyCode == 8) {
                //判断输入框里是否为空，为空时退格键触发删除标签
                if (content == "") {
                    //获取里输入框最近一个标签的id，然后删除，并通过id定位到便签原来的位置并显示出来
                    var numid = $(".add input").prev().attr('id');
                    $(".add input").prev().remove();
                    $(".label_type span").eq(numid).show();
                }
            } else if (e.keyCode == 13 || e.keyCode == 32) { //回车键和空格键事件
                //调用函数
                autocomplete();
            }
        });
        //输入框失去焦点时进行匹配生成标签
        $("input").blur(autocomplete);
```

> * autocomplete()函数如下。这里对输入的标签通过for循环一个一个与标签列表进行匹配

``` bash
        //遍历匹配生成对应标签
        function autocomplete() {
            var content = $("input").val();
            //获取标签的总个数，用于遍历
            var len = $(".label_type").children().length;
            //遍历标签，判断输入的是否存在于标签了
            for (var i = 0; i < len; i++) {
                var con = $(".label_type span").eq(i).text();
                //这里判断输入框里是否为空，并且进行匹配，输入只需要匹配到部分，方便输入
                if (content != "" && con.match(content)) {
                    $(".label_type span").eq(i).clone().insertBefore($(".add input")).addClass("ad").attr('id', i).append("<b class='close'>ⓧ</b>");
                    $(".label_type span").eq(i).hide();
                    $("input").val("");
                }
            }
        }
```
### Demo和源码 ###
[效果展示：Demo](http://calltesting.sinaapp.com/tags/tags.html)
[源代码地址](https://github.com/hhking/Label_operation)