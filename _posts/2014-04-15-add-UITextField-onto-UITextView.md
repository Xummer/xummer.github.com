---
layout: post
title: 在UITextView中加UITextField作为Header
date: 2014-04-15     T
meta: ture
---
在`UITextView`中加`UITextField`，若不做任何处理，`UITextField`成为`firstResponder`后会移动到中间。

之前

![](https://github.com/Xummer/UITextViewWithHeader/raw/master/defualt.png)

点击`UITextField`以后

![](https://github.com/Xummer/UITextViewWithHeader/raw/master/become_first_responder.png)

发现DayOne也有这样的结构，

![](../images/blog-images/2014-04-15/dayone.jpg)

用reveal查看DayOne后发现它在`TextField`下面加了一层`UIScrollView`, 问题解决。

![](https://github.com/Xummer/UITextViewWithHeader/raw/master/dayone_textview.png)

以下只是几种情况的猜测   

1. `UITextField`监听`subview`的`becomeFirstResponder`  
① `UITextField`在`becomeFirstResponder`时传递某个消息S到`UITextView`;   
② `UITextView`接收到这个消息S，获取`firstResponder`的`UITextField`往`SuperView`递归查找第一个`UIScrollView`或`UIScrollView`子类化的`viewA`;  
③ 重设`viewA`的`contentOffset`;
  
2. `UITextView`监听键盘事件  
① 获取`firstResponder`，然后发送全局的消息S（`NSNotificationCenter`;  
②③同1的②③

-以上-
