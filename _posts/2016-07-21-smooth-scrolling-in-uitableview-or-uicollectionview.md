---
layout: post
title: iOS 复杂 UITableView/UICollectionView 流畅滑动
date: 2016-07-21     T
meta: ture
---

## 问题
我们使用的是一个 `UITableView` 套用 `UICollectionView` 的一个结构，在 iPhone 6 上 `tableView` 的上下滚动还会造成明显的卡顿。但事实上 FPS 没有怎么下降。[FPS 不能作为卡顿时间的目标](https://github.com/facebook/AsyncDisplayKit/issues/204)

##  基础知识
### iOS 显示原理
借用下 ibireme 大神的一张图
![](http://blog.ibireme.com/wp-content/uploads/2015/11/ios_screen_display.png)

#### 1、 CPU 计算显示内容提交给 GPU ，如：视图的创建、布局计算、图片解码、文本绘制
#### 2、 GPU 渲染后将结果放入 FrameBuffer (帧缓冲区)
FrameBuffer 中存放的是你在屏幕上看到的所有像素的颜色值和半透明值(RGBA)
#### 3、 视频控制器按照 VSync(垂直同步信号) 读取 FrameBuffer 显示的屏幕上

### 罪魁祸首 ？掉帧

> 如果在一个 VSync 时间内，CPU 或者 GPU 没有完成内容提交，则那一帧就会被丢弃，等待下一次机会再显示，而这时显示屏会保留之前的内容不变。<br>
>		 —  ibireme 

再借一张(逃
![](http://blog.ibireme.com/wp-content/uploads/2015/11/ios_frame_drop.png)

## 问题查询

![](http://ww2.sinaimg.cn/large/006tNc79gw1f5q2rif6scj31b00n44f0.jpg)


### 初步分析以及解决方案
从 Time Profiler 的结果上分析可以看到

1. `[AMAppTitleLabel textRectForBounds:limitedToNumberOfLines:]` 以及 `[AMAppTitleLabel drawTextInRect:]` 消耗了大部分 cpu 计算时间，其实这里我们为了一个效果重写了一个 `DrawRect` 方法导致的，改为计算 frame 的方式来实现同样的效果。

2. `[AMMainFrameViewModel configureCell:forRowAtIndexPath:]` 
这是 `UITableView` delegate `- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath` 中每一行调用的方法, 看下具体的实现
![](http://ww3.sinaimg.cn/large/006tNbRwgw1f5y3nv7egaj30dz09wacq.jpg)
大部分的 CPU 的时间消耗在 `addSubView` 上，这其实和下面一条 AutoLayout 是相关的。还有之后的 `[UIView(Extend) removeAllSubviews]`。尽量将 cell 做成单一可重用的，避免在滚动中的添加和移除操作。

3. `[MASViewConstraint install]` AutoLayout 很大提升了我们开发的效率，但是对于相对复杂的视图会带来严重的性能问题。
AutoLayout 根据给定的约束去计算 frame 再设置，和人为的计算好 frame 直接设置，结果可想而知。[pilky.me](http://pilky.me/36/)
![](http://pilky.me/static/blogmedia/optimiseautolayout2.png)
所以对 2、3 两点的优化方案就是 尽量减少视图层级，移除 AutoLayout 改为手动设置 frame。

### GPU 问题
以上基本是 CPU 的计算问题, 下面来说说 GPU 的消耗
#### 图片加载过程
大部分还都是 CPU 的活

```
    // 伪代码    

    UIImage *img = [[UIImage alloc] initWithContentsOfFile:path];
    UIImageView.image = img;
    // UIImageView.layer.contents = img.CGImage;
    
    [UIImageView moveToWindow];
    
    if ([UIImageView.layerTree changed]) {
        CGContextRef bitmap;
        if ([img isPNG] || [img isJPG]) {
            bitmap = [CPU tryToDecode];
        }
        else {
            bitmap = img.CGImage;
        }
        
        if (![bitmap isByteAlign]) {
            bitmap = CA::Render::copy_image(bitmap);
        }
        [GPU drawBitmap:bitmap];
    }
```


>1. 从磁盘拷贝数据到内核缓冲区
>2. 从内核缓冲区复制数据到用户空间
>3. 生成UIImageView，把图像数据赋值给UIImageView
>4. 如果图像数据为未解码的PNG/JPG，解码为位图数据
>5. CATransaction捕获到UIImageView layer树的变化
>6. 主线程Runloop提交CATransaction，开始进行图像渲染 <br>
>   6.1 如果数据没有字节对齐，Core Animation会再拷贝一份数据，进行字节对齐。<br>
>   6.2 GPU处理位图数据，进行渲染。<br>
>       -- bang

#### 视图叠加
##### alpha ＝ 1
![](http://ww3.sinaimg.cn/large/006tNbRwgw1f5zdvg1ncsj30m80m8t9y.jpg)

##### alpha = 0.5
![](http://ww4.sinaimg.cn/large/006tNbRwgw1f5zdvfqntkj30m80m8q41.jpg)

frameBuffer 里都是都是展开的 RGBA, 视图叠加的操作就是对 S 和 D RGBA 的操作。

##### 公式

```
R = S + D * ( 1 – Sa )
```

套用 alpha = 0.5 时整个公式的计算结果如下

```
S RGBA (1,0,0,0.5)
D RGBA (0,0,1,1)
                       0.5   0               0.5
R = S + D * (1 - Sa) = 0   + 0 * (1 - 0.5) = 0
                       0     1               0.5
```

#### 离屏渲染
- border、圆角、阴影、遮罩(mask) 触发离屏渲染
- 另外开辟一块缓冲区(OffScreenBuffer)来做渲染的操作
- CALayer.shouldRasterize 光栅化，将离渲染的结果保存为位图(bitmap)存储起来复用，从而减少离屏渲染的次数

##### 为什么要避免离屏渲染
###### GPU 平时要做的
- 在 frameBuffer 里渲染好需要显示的内容

###### GPU 在离屏渲染时要做的
- 从 frameBuffer 跑到 OffScreenBuffer 渲染好离屏部分内容
- 将 OffScreenBuffer 中的内容合并到 frameBuffer

###### 离屏幕渲染时需要更多的操作
- 开辟了新的缓冲区 OffScreenBuffer
- 渲染内容的合并
- 2 次昂贵的环境切换

### 横向滚动卡顿
优化了这些问题后还是有点卡顿？横向滚动卡顿。AppStore 做了神马操作？
逆向 AppStore 看看。过程比较复杂可以另外写一篇记录了。

逆向时发现还有这么几个点:

#### App icon 圆角的绘制

从 iOS 7 开始，App 的 icon 改进了一次图标的圆角。

```
// 并不是这么实现的
layer.cornerRadius = 5.0f;
```

![](http://ww3.sinaimg.cn/large/006tNbRwgw1f61kowj78qj309r09ljsj.jpg)

1. 由 A 反向蒙板生成 B;
2. 以 B 为蒙板生成圆角 C;
3. 将 D 和 C 绘制生成一张带边框的图片;
4. 将处理后图片缓存起来;

##### 进一步优化
###### 1.异步绘制
AppStore 在未加载完时仍会卡顿，未实现异步绘制。
应为 CoreGraphic 线程安全，异步绘制也较容易实现。

```
- (void)display {
    dispatch_async(backgroundQueue, ^{
        CGContextRef ctx = CGBitmapContextCreate(...);
        // draw in context...
        CGImageRef img = CGBitmapContextCreateImage(ctx);
        CFRelease(ctx);
        dispatch_async(mainQueue, ^{
            layer.contents = img;
        });
    });
}
```

###### 2.可取消的绘制
当 cell 滑出屏幕时未取消该 cell 上绘制，SDWebImage 有实现取消加载的操作。简单的实现方式就是 **在每次绘制前，判断是否已取消**

```
- (void)_backgroundDrawImageForImage:(UIImage *)image cacheWithUrl:(id)url
                           completed:(AMUIImageCompletionBlock)complete
{   
    NSString *key = [[self class] _keyForImageUrl:url];
    
    if ([self _isDrawingCanceled:key]) {
        return;
    }
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        
        if ([self _isDrawingCanceled:key]) {
            return;
        }
        
        // Draw image
        
        if ([self _isDrawingCanceled:key]) {
            return;
        }
        
        UIImage *iconImg = UIGraphicsGetImageFromCurrentImageContext();
        
        if (complete) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if ([self _isDrawingCanceled:key]) {
                }
                else {
                    complete(iconImg, nil, url);
                }
            });
        }
    });
}
```

#### 滚动时的阻力 
decelerationRate 0.899999976158; // 0x3f666666

- AppStore
![](http://ww4.sinaimg.cn/large/006tNbRwgw1f5y7fbigtyg30mo0ec7wh.gif)
- Custom
![](http://ww1.sinaimg.cn/large/006tNbRwgw1f5y7f8flelg30mo0cokjm.gif)

#### 滚动停止时，加载图片。
![](http://ww2.sinaimg.cn/large/006tNbRwgw1f5y7ujtvr4j30tu042ta1.jpg)

### 另外的优化点
1. 将计算布局的结果保存起来避免同样的内容多次计算;
2. 减少视图层级，可绘制成1张图片显示;
3. 将没有点击事件的 `UIView` 换成 `CALayer` 实现;
4. 减少设置视图的 `frame/bounds/transform`;
5. 去 Storyboard ，性能敏感界面直接代码创建 View 对象;

### 参考文章
- [iOS 保持界面流畅的技巧 - ibireme](http://blog.ibireme.com/2015/11/12/smooth_user_interfaces_for_ios/)
- [绘制像素到屏幕上](https://objccn.io/issue-3-1/)
- [WWDC心得与延伸:iOS图形性能 - 方秋枋](http://www.cocoachina.com/ios/20150429/11712.html)
- [iOS 视图---动画渲染机制探究 - 腾讯Bugly特约作者 陈向文](http://www.cocoachina.com/ios/20151229/14811.html?utm_source=tuicool&utm_medium=referral)
- [微信iOS卡顿监控系统](http://mp.weixin.qq.com/s?__biz=MzAwNDY1ODY2OQ%3D%3D&idx=1&mid=207890859&scene=23&sn=e98dd604cdb854e7a5808d2072c29162&srcid=0921FzoCw9j1W7n4uFYKuarC#rd)
- [iOS实时卡顿监控](http://www.tanhao.me/code/151113.html/)
- [微信读书 iOS 性能优化总结](http://wereadteam.github.io/2016/05/03/WeRead-Performance/)
- [iOS 10 UITableView 和 UICollection View 新增 API](https://developer.apple.com/videos/play/wwdc2016/219/)
- [iOS图片加载速度极限优化—FastImageCache解析 bang](http://blog.cnbang.net/tech/2578/)


-以上-


