---
layout: post
title: UIImagePickerController iOS7 状态栏颜色
date: 2014-05-07     T
meta: ture
---

iOS7 的 SDK 中 `UIViewController`多了2个控制 StatusBar 的方法，

```
- (UIStatusBarStyle)preferredStatusBarStyle NS_AVAILABLE_IOS(7_0); // Defaults to UIStatusBarStyleDefault

- (BOOL)prefersStatusBarHidden NS_AVAILABLE_IOS(7_0); // Defaults to NO
```

但是`UIImagePickerController`我们无法在里面改写方法, 首先找到方法，推出`UIImagePickerController`之前,设置全局的statusBarStyle.

### 设置全局的statusBarStyle 无效）

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

### 解决方法 子类化UIImagePickerController

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
