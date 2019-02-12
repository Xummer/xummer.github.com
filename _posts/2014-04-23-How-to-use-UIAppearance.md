---
layout: post
title: UIAppearance 的使用
date: 2014-04-23     T
meta: ture
---
## UIAppearance

iOS 5 以后加了 `UIAppearance` 来控制 UI 的全局的显示 `+ appearance` 或某一个类中的显示 `+ appearanceWhenContainedIn:`.

`UIAppearance` 只对有 `UI_APPEARANCE_SELECTOR ` 标示的 `property` 有效，如 `UINavigationBar.h => tintColor`

```
@property(nonatomic,retain) UIColor *barTintColor NS_AVAILABLE_IOS(7_0) UI_APPEARANCE_SELECTOR; 
```

Apple 提供的方法

```
+ appearance
+ appearanceWhenContainedIn:
```

用法

```
[UINavigationBar appearance].barTintColor = [UIColor redColor];
```

### 没有 UI_APPEARANCE_SELECTOR 的解决方法

创建 Category, 并添加带有 `UI_APPEARANCE_SELECTOR ` 标示的 property，虽然 Category 不能通过正常(这里不说 runtime)加变量，但是这边只是用了 `setter` 方法，并没有实际用到这个 property。

```
// ====== .h ======

#import <UIKit/UIKit.h>

@interface UILabel (Appearance)

@property (assign, nonatomic) UIColor *labelBackgroundColor UI_APPEARANCE_SELECTOR;

@end

// ====== .m ======

#import "UILabel+Appearance.h"

@implementation UILabel (Appearance)
@dynamic labelBackgroundColor;

- (void)setLabelBackgroundColor:(UIColor *)labelBackgroundColor {
    [super setBackgroundColor:labelBackgroundColor];
}

@end
```

```
[[UILabel appearance] setLabelBackgroundColor:[UIColor clearColor]];
```

### 参考资料
* [NSHipster UIAppearance](http://nshipster.com/uiappearance/)
* [统一设计，iOS6也玩扁平化](http://esoftmobile.com/2014/01/14/build-ios6-ios7-apps/)
* [SO - iOS: Using UIAppearance to define custom UITableViewCell color](http://stackoverflow.com/questions/8316543/ios-using-uiappearance-to-define-custom-uitableviewcell-color)


-以上-
