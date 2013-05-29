---
layout: post
title: "从nib初始化自定义view"
date: 2013-01-13 21:09
meta: true
---
Xcode中用IB直接创建nib文件(PS:关于nib文件，之前的IB中所创建的可视化控件都是以nib结尾的，所以叫nib文件。虽然现在见不到nib了，都变为xib了但是还是称为nib文件)确实是很快，一些简单的view直接就可以用IB直接拖控件，节省了很多时间。在创建的UIViewController时确实很方便，但是创建自定义的UIView时却有一些麻烦。  
![](/images/blog-images/2012-1-13/newCustomView.png)  
创建时没有自带的xib的选项，所以创建完自定义view之后要直接拖控件的话得自己在创建一个xib文件并做连接。  
![](/images/blog-images/2012-1-13/newXib.png)   

设置xib的名称  

![](/images/blog-images/2012-1-13/newXib2.png)  

<del>之后将xib的File's Owner中的Custom Class改为刚才所创建的自定义view的名字我这是`TestView`。</del>  

###之前没有完全理解File's Owner到底是用来干嘛的，写的有些错误。看了[这篇文章](http://www.cnblogs.com/martin1009/archive/2012/06/01/2531028.html) ，里面说道
***
   iPhone开发广义上来讲，采用MVC模型，即Model-View-Controller。其中：
    * Model为数据模型，比如用户配置文件；
    * View为显示的界面元素，比如一个按钮；
    * Controller为控制器，是Model和View之间进行沟通的桥梁。  
   其中View和Model之间不会直接通信，即Model只能与Controller之间进行彼此通信，View只能与Controller之间进行通信。

##File's Owner  
   重点就是这里了，`View`和`ViewController`之间的对应关系，需要一个桥梁来进行连接的（即，对于一个视图，他如何知道自己的界面的操作应该由谁来响应），这个桥梁就是`File's Owner` 。  
   选中某个XIB的File's Owner，在Inspector中可以看到属性：File Name和Custom Class，该File's Owner就是用来绑定`File Name`中的xib文件和`Custom Class`中的`ViewController`的，在做了这个绑定之后，按住`control`键，拖动`File's Owner`到`xib`中的某个控件的时候，就是`Custom Class`中定义的`IBOutlet`元素与`xib`中元素进行连接的过程，同样，拖动"`xib`中的控件的动作"到`File's Owner`的时候，就是将`xib`中该动作的响应与`Custom Class`中某个`IBAction`进行连接的过程。  
   因此，在存在多个`xib`文件的情况下，即：有多个`View`，那么每个View可以采用不同的`ViewController`，也可以全部采用相同的一个`ViewController`，通过`File's Owner`进行关联即可。  
   其实，`File's Owner`就是`Custom Class`类型的对象，而`xib`中的其他元素都是该对象的成员变量，但是需要手动来关联`Custom Class`中的成员变量与`xib`中对象之间的关系。
***  
所以我们这边的xib并不需要关联到对应的`ViewController`，所以也不需要设置File's Owner。保持默认的`NSObject`就可以了。  
  
![](/images/blog-images/2012-1-13/customClassRight.png)
 
需要设置的是Xib中的最底层view的`Custom Class`改为刚才所创建的自定义view的名字我这是`TestView`
  
![](/images/blog-images/2012-1-13/ObjectTestView.png)   
 
![](/images/blog-images/2012-1-13/customClass.png)   

之后就可以拖控件了。拖IBOutlet的property。

***
以上控件是拖好了，然后来说从xib文件中初始化实例。  

方法一，直接用

```objc
NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"TestView" owner:self options:nil];
TestView *subView = [nibViews objectAtIndex:0];
```
从nib文件中获取实例，应为这个实例是autorelease的，所以如果不是用ARC的同学自己retain一次。但是种种方法每次都这么初始化感觉比较麻烦。  
  
方法二，网上看到的方法，google搜自定义UIView搜到的基本上都是这个方法，但是存在很大的问题，不推荐。 

```objc
- (id)initWithNib {
	self = [super init]; 
	if (self) {
		NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"TestView" owner:self options:nil];
		TestView *subView = [nibViews objectAtIndex:0];
		[self.view addsubView subView];
	}
	return self;
}
```

这就有个明显的问题，它是将取到的实例加在`self.view`上显示的，其实`subView`就已经是一个`TestView`的实例了,`self`自然也是一个`TestView`的实例。将`TestView`的实例加在另一个`TestView`实例上显示这感觉就多此一举了。而且还会存在一个问题，当`TestView`中有其他`property`这就会有问题出现了,比如这个`property`是`UILabel nameLabel`。当你具体要使用这个`nameLabel`是就会出现问题。如，

```objc
TestView *tView = [[TestView alloc] initWithNib];
[tView.nameLabel setText:@"just 4 test"];
```
这里就会看到无论你怎么设置这个`nameLabel`都不能在UI上改变。
原因就是你`setText`的`nameLabel`就是上面的`self`这个实例A，而在UI上显示的则是从nib初始化出来的实例B`subView`。A和B不同，修改A，B还是B。  
虽然可以通过其他方式将A和B联系起来但是感觉还是多此一举。
  
方法三，其实也就是方法一，将他封装下而已，但是下面我们来看下关于ios内存管理的问题。

```objc
- (id)initWithNib {
	NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"TestView" owner:self options:nil];
	TestView *subView = [nibViews objectAtIndex:0];
	return [subView retain]; //必须要retain 
}
``` 

一般初始化之后，都`addSubview`到其他的`view`上去了。这种情况不`retain`也没有什么问题,因为`addSubview`中做了系统做了一次`retain`操作。但是需要用到`removeFromSuperview` 那问题就出现了。。。分析下主要是内存的管理问题,重新来看下自定义`view`的 `retainCount` 

```objc
- (id)initWithNib {
	NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"TestView" owner:self options:nil];
	TestView *subView = [nibViews objectAtIndex:0]; // [subView retainCount] = 1 为autorelease 内存地址0x1234 (随意定义说明用)
	return [subView retain]; //必须要retain         // [subView retainCount] = 2 内存地址0x1234
}
```

若没有`subview` 没有 `retain`那来分析下

```objc
- (id)initWithNib {
	NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"TestView" owner:self options:nil];
	TestView *subView = [nibViews objectAtIndex:0]; // [subView retainCount] = 1 为autorelease 内
存地址0x1234 (随意定义说明用)
	return subView;         			    // [subView retainCount] = 1 内存地址0x1234
}
```

```objc
@interface ViewController : UIViewController
@property (retain, nonatomic) TestView *testView;
@end

@implementation ViewController
- (void)initTestView {
	TestView *tView = [[TestView alloc] initWithNib]; // [tView retainCount] = 1   autorelease 内存地址0x1234
	[self.view addSubview:tView];                     // [tView retainCount] = 2 内存地址0x1234
	self.testView  = tView;                           // [testView retainCount] = 3 内存地址0x1234
	[tView release];                                  // [testView retainCount] = 2 内存地址0x1234
}
	/*
 	 …        //tView 的 @autoreleasepool销毁        [testView retainCount] = 1 内存地址为0x1234
	*/
	
- (void)removeTestViewFromSuper {
	[_testView removeFromSuperview];                 // [testView retainCount] = 0 内存地址0x1234  调用TestView的dealloc函数销毁，但是0x1234内存地址的所对应的值未被置为nil
}
	/* 
	 … self 的retainCount = 0 系统调用dealloc销毁self  但是dealloc中存在 [_testView release];       系统对0x1234发送release消息，导致crash
	*/

- (void)dealloc {
	[_testView release];                             // testView 的实例已经不存在 
	[super dealloc];
}     
 
@end
```
所以还是推荐第三种方法，必须加`retain`。

```objc
- (id)initWithNib {
	NSArray *nibViews = [[NSBundle mainBundle] loadNibNamed:@"TestView" owner:self options:nil];
	TestView *subView = [nibViews objectAtIndex:0]; /*          做view的初始化操作        */
	return [subView retain];  
}
```
