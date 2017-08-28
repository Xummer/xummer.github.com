---
layout: post
title: 用系统控件实现 “你的名字” 中的 NavigationBar
date: 2016-12-28     T
meta: ture
---

随着“你的名字”在中国的热映, 各种仿 My Diary 的 App 层出不穷。大部分在 UI 上还都是比较粗糙的。本文将使用 iOS **私有 api** 实现顶部 NavigationBar 的效果。如果使用将无法通过 AppStore 审核，~~但不是还有 JSPatch 嘛~~（笑。

先上一个图

![](https://ww3.sinaimg.cn/large/006tNc79jw1fb6uto7m0cj30sk0nidkr.jpg)

大家都知道 iOS 7 以上 `UINavigatinBar` 默认的高度是 64 (44 NavigationBar + 20 statusBar), 系统也没有给出可以自定义 NavigationBar 的方法，如果要实现这个效果基本上就是再自己重写一个空间了。但是我们能看到在 AppStore 中是有类似实现的，具体如下图。

![](https://ww4.sinaimg.cn/large/006tNc79gw1fb6uzptma5j30hs0vkmzh.jpg)

也就是说 Apple 是有这个控件的，只是藏起来而已，用 Reveal 看了下后发现是一个 `_UINavigationControllerPalette` 类，[RuntimeHeader](https://github.com/nst/iOS-Runtime-Headers/blob/master/Frameworks/UIKit.framework/_UINavigationControllerPalette.h) 还是在 UIKit 里的，好了到这里就知道我们也可以调用这些私有 api 来实现这个效果。

> Talk is cheap, show me the code.

主要用到的私有 API 有以下这些：

```objc
@interface _UINavigationControllerPalette : UIView

- (id)_initWithNavigationController:(UINavigationController *)navigationCtrl forEdge:(unsigned int)edge;

- (void)_setPinningBar:(UINavigationBar *)navigationBar;

@end

@interface UINavigationController ()

- (void)attachPalette:(_UINavigationControllerPalette *)palette isPinned:(BOOL)isPinned;

- (void)_detachPalette:(_UINavigationControllerPalette *)palette;

@end
```

关键代码 [Github](https://github.com/Xummer/MyDiaryNavigationBar)

```objc
_UINavigationControllerPalette *palette = [[_UINavigationControllerPalette alloc] _initWithNavigationController:self.navigationController forEdge:0];
[palette _setPinningBar:self.navigationController.navigationBar];
    
palette.frame = (CGRect){
   .origin.x = 0,
   .origin.y = 64,
   .size.width = CGRectGetWidth(self.navigationController.view.frame),
   .size.height = 38
};
    
UILabel *titleLabel = [[UILabel alloc] initWithFrame:palette.bounds];
titleLabel.textAlignment = NSTextAlignmentCenter;
titleLabel.text = @"Diary";
titleLabel.textColor = MAIN_TINTCOLOR;
titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
[palette addSubview:titleLabel];
    
[self.navigationController setValue:palette forKey:@"_topPalette"];
    
self.navigationItem.titleView = [[UISegmentedControl alloc] initWithItems:@[@"Entries", @"Calendar", @"Dairy"]];

// 使其显示
[self.navigationController attachPalette:palette isPinned:YES];

// 取消显示
[self.navigationController _detachPalette:palette];

```

最终效果图

![](https://ww4.sinaimg.cn/large/006tNc79jw1fb6wv84ei7j30ku1123ze.jpg)


-以上-


