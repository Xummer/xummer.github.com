---
layout: post
title: "使用 CATransaction flush设置cube动画的两个面"
date: 2013-01-23 23:20
meta: true
---
最近项目动画比较多，主要用到`CATracnsaction`的`cube`动画。但是遇到个问题，举个例子来说：`self.view`一开始的背景颜色为灰色，在加`cube`动画之前设置`self.view`的背景为红色，会出现由灰色背景到红色背景的`cube`动画。如下图,  
  
![](/images/blog-images/2013-1-23/noFlush.png)  

代码  

```objc
[self.view setBackgroundColor:[UIColor redColor]];
CATransition *transition = [CATransition animation];

transition.type = @"alignedCube";
transition.subtype = kCATransitionFromTop;
transition.duration = 0.5;
transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
transition.repeatCount = HUGE_VALF;
//    transition.repeatDuration = 1.0f
transition.delegate = self;
[self.view.layer addAnimation:transition forKey:@"transition"];
``` 
  
## 使用[CATransaction flush]
若在设置红色背景后加`[CATransaction flush];`就可以实现`cube`动画两个界面都是红色了。如图,  

![](/images/blog-images/2013-1-23/withFlush.png)  

代码   
 
```objc
[self.view setBackgroundColor:[UIColor redColor]];
[CATransaction flush];
CATransition *transition = [CATransition animation];
    
transition.type = @"alignedCube";
transition.subtype = kCATransitionFromTop;
transition.duration = 0.5;
transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
transition.repeatCount = HUGE_VALF;
//    transition.repeatDuration = 1.0f
transition.delegate = self;
[self.view.layer addAnimation:transition forKey:@"transition"];
```
  
## 总结  
`CATransaction`的`cube`动画有一个缓存一样的机制，因为要显示两个`view`的`layer`，若不加`[CATransaction flush]`则系统默认为在`[self.view.layer addAnimation:transition forKey:@"transition"];`之前的对`view`的操作全部作为动画的内容。`addAnimation`时从缓存中取出之前的`view`的`layer`，作为`cube`中即将消失的一面，在将所有的改动后的`view`的`layer`作为`cube`新的一面。`[CATransaction flush]`起到了分割线的作用。
     
     之前，存入缓存，作为cube中即将消失的一面
     ------------------------
      [CATransaction flush];
     之后，改动view直到addAnimation之前作为cube中新的一面
     ------------------------
      [self.view.layer addAnimation:transition forKey:@"transition"];


