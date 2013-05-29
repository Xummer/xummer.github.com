---
layout: post
title: "ios系统相册选择视频后的处理"
date: 2012-11-07 21:58
meta: true
---
最近用GPUImage这个开源类库给视频加滤镜效果，之中有一个从系统相册选择视频的处理的过程。  
调用系统相册（别忘了加这两个协议 ``<UINavigationControllerDelegate,UIImagePickerControllerDelegate >``）
  
```objc  
- (void)pushToAlbumView {
	UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
	imagePickerController.mediaTypes = [UIImagePickerController availableMediaTypesForSourceType:UIImagePickerControllerSourceTypeSavedPhotosAlbum];
	imagePickerController.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	imagePickerController.delegate = self;
	//    imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
	//    imagePickerController.allowsEditing = YES;
	[self presentViewController:imagePickerController animated:YEScompletion:NULL];
}
``` 
在实际过程中发现,在选择视频后会有一个视频压缩的问题(模拟器上编译通不过，需要真机测试)。
![](/images/blog-images/2012-11-07/videoCompress.png )   

```objc
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
```
而是在这之前，目前并没有找到具体在哪里调用，具体压缩消耗的时间和视频的本身大小有关。

而在压缩完之后想要推出一个模态视图``ModalViewController`` ，必须将当前的``ModalViewController`` dismiss掉然后再新推一个``ModalViewController``，但是问题是不知道何时会压缩处理完，在当前的``ModalViewController`` 消失掉之前推出一个``ModalViewController``，就会crash。

找了半天关于视频压缩的，还是没有找到答案，在``ModalViewController``中找到了解决方法，（只支持5.0及以后的系统）在block中设置一个回调块，在这个块中推出一个新的``ModalViewController``。

```objc
// The completion handler, if provided, will be invoked after the dismissed controller's viewDidDisappear: callback is invoked.
- (void)dismissViewControllerAnimated: (BOOL)flag completion: (void (^)(void))completion NS_AVAILABLE_IOS(5_0);
```
具体如下  

```objc
[picker dismissViewControllerAnimated:YES completion:^(void){
	UIViewController *PVC = [[UIViewController alloc] init];
	[self presentViewController:PVC animated:YES completion:NULL];
	[PVC release];
}];
```
