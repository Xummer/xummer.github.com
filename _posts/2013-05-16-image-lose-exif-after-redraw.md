---
layout: post
title: "图片压缩后原有旋转信息丢失"
date: 2013-05-16 23:04
meta: true
---
近期做微博分享，iPhone 调用系统相机拍摄照片后，图片过大大概有 15M 左右，新浪微博最大支持 5M 的图片上传。所以必须先在本地做个压缩。  
  
## 图片压缩方法
1. 重绘，改变图片的 size，来达到压缩的目的
2. 图片格式转换，通过修改图片的质量来，改变图片的文件大小

## 修改图片质量
先来看修改图片质量,系统提供了两个方法  
I、转 png  

```objc
NSData *UIImagePNGRepresentation(UIImage *image);                               
// return image as PNG. May return nil if image has no CGImageRef or invalid bitmap format
```  
II、转 jpeg

```objc
NSData *UIImageJPEGRepresentation(UIImage *image, CGFloat compressionQuality);  
// return image as JPEG. May return nil if image has no CGImageRef or invalid bitmap format. compression is 0(most)..1(least)
```
  
具体来转换后的效果
之前测试的一个图片 jpeg  
3.2M 原图  
5.5M `UIImageJPEGRepresentation(image, 1)`  
385K `UIImageJPEGRepresentation(image, 0)`	
14.1M `UIImagePNGRepresentation(image)`	   

现在压缩一个小图 大家都丧心病狂的黑香菜[兵库北](http://wiki.acfun.tv/index.php?title=%E5%85%B5%E5%BA%93%E5%8C%97&diff=0&oldid=53841)我也来黑下吧 括弧笑
 
测试代码  

```objc
NSString *filePath = nil;
UIImage *image = [UIImage imageNamed:@"Bingkubei.jpg"];
filePath = [NSTemporaryDirectory() stringByAppendingFormat:@"tmp.png"]; // 所有我都存成png的后缀了，大小貌似和后缀没什么关系。
[UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
```  
  
105k 原图  
![](/images/blog-images/2013-5-16/Bingkubei.jpg)  
259k `UIImageJPEGRepresentation(image, 1)`  
![](/images/blog-images/2013-5-16/BingkubeiJpeg1.png)  
20k `UIImageJPEGRepresentation(image, 0)` 直接就渣画质了  
![](/images/blog-images/2013-5-16/BingkubeiJpeg0.png)  
596k `UIImagePNGRepresentation(image)`  
![](/images/blog-images/2013-5-16/BingkubeiPNG.png)

****
结论：压缩的话还是要用 `UIImageJPEGRepresentation(image, 0.26)` 这个方法。

## 修改图片质量产生的问题
修改图片质量后后图片的 exif 信息都丢失了，也就是说之前用 iPhone 竖屏拍摄的照片在压缩存储后就变成横屏的（看上去倒过来了），iOS 机器上看不出来，但是一分享到微博，问题就出现了。  
如下图：  
![](/images/blog-images/2013-5-16/shareSina.png)

## 解决方法  
这里我们就要用到重绘了。在压缩存储前将图片重绘一次，应为这时候图片是带有旋转信息的，所以绘制出的是你拍摄正常方向的图片。之后再进行图片质量的压缩`UIImageJPEGRepresentation(image, 0.26)`。  
重绘代码

```objc
// 重绘图片到指定宽度 clip: 是否切处过长的边界切成正方形
+ (UIImage *)scaleImage:(UIImage *)image newWidth:(CGFloat)iWidth clip:(BOOL)isClip {
	//    NSLog(@"image size:%f,%f",image.size.width, image.size.height);
	if (image.size.width > iWidth) {
		CGFloat minValue = MIN(image.size.width, image.size.height);
		float scaleFloat = iWidth/minValue;
		CGSize size = CGSizeMake(isClip?iWidth:scaleFloat*image.size.width, isClip?iWidth:scaleFloat*image.size.height);
		
		UIGraphicsBeginImageContext(size);
		CGContextRef context = UIGraphicsGetCurrentContext();
		CGAffineTransform transform = CGAffineTransformIdentity;
		
		transform = CGAffineTransformScale(transform, scaleFloat, scaleFloat);
		CGContextConcatCTM(context, transform);
		
		// Draw the image into the transformed context and return the image
		[image drawAtPoint:CGPointMake(0.0f, 0.0f)];
		UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
		UIGraphicsEndImageContext();
		
		return newimg;
	}else{
    	return image;
    }
}
```

-以上-
