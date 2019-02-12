---
layout: post
title: UIImagePickerController iOS 7 状态栏颜色
date: 2014-05-07     T
meta: ture
---
需要自定义推出的 `UIImagePickerController` 的导航栏，但是推出的后的 StatusBar 一直是深色的。

#### 默认风格
![](https://farm8.staticflickr.com/7347/13959527109_259ba87b75_n.jpg)

#### 自定义后出现的效果
![](https://farm8.staticflickr.com/7384/14166265013_de3af7ff77_n.jpg)

#### 最终需要的效果
![](https://farm3.staticflickr.com/2924/14146382834_273e896442_n.jpg)

iOS 7 的 SDK 中 `UIViewController` 多了 2 个控制 StatusBar 的方法，

```
- (UIStatusBarStyle)preferredStatusBarStyle NS_AVAILABLE_IOS(7_0); // Defaults to UIStatusBarStyleDefault

- (BOOL)prefersStatusBarHidden NS_AVAILABLE_IOS(7_0); // Defaults to NO
```

但是 `UIImagePickerController` 我们无法在里面改写方法, 首先找到方法，推出 `UIImagePickerController` 之前,设置全局的 statusBarStyle.

### 设置全局的 statusBarStyle 无效

实测 iOS 7.1 无效

```
#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController
      willShowViewController:(UIViewController *)viewController
                    animated:(BOOL)animated {
    
    if ([navigationController isKindOfClass:[UIImagePickerController class]] &&
        ((UIImagePickerController *)navigationController).sourceType == UIImagePickerControllerSourceTypeSavedPhotosAlbum) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent animated:NO];
    }
}
```

### 解决方法 子类化 UIImagePickerController

```
@interface CustomImagePickerController : UIImagePickerController
@end

@implementation CustomImagePickerController
- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent; // change this to match your style
}
@end
```

### NavigationBar

`UIImagePickerController` 的 `NavigationBar` 默认带了毛玻璃效果，若要取消

```
picker.navigationBar.translucent = NO;
```

-以上-
