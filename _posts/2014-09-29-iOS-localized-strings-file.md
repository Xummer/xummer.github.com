---
layout: post
title: iOS本地化的strings文件
date: 2014-09-29     T
meta: ture
---
# iOS本地化的strings文件

很多本地化都教程都提到了如何去做多语言的`.strings`文件, 然后在代码中调用`NSLocalizedString(key, comment)`就好了。
这里来说下`.strings`文件。

## .strings文件
在创建project时，Xcode会自动生成`InfoPlist.strings`。
`InfoPlist.strings`是用来做一些App系统显示层面上的本地化的（如App 名字）。还有一个是代码中用到的字符串用宏`NSLocalizedString(key, comment)`做本地化默认`.strings`文件—`Localizable.strings`。当然，你也可以自定义其他的`.strings`来做代码中的本地化，不过就要用宏`NSLocalizedStringFromTable(key, tbl, comment)`来指定`.strings`文件的来源。

列个表格看下

strings名称 | 作用
--- | --- 
InfoPlist.strings | App系统显示层面上的本地化的（如App 名字）
Localizable.strings | 代码中用到的字符串用宏`NSLocalizedString(key, comment)`做本地化默认`.strings`文件
xxx.strings | 自定义本地化文件，用宏`NSLocalizedStringFromTable(key, tbl, comment)`来指定`.strings`文件的来源

## .strings格式
```
key = value ; 
```

例子
```
@“Name” = @“名称”;
CFBundleDisplayName = @“啊呸呸”;
```

## infoPlist.strings
正如其名字描述的，对 xxInfo.plist 的中描述的本地化。

- [Cocoa Keys](https://developer.apple.com/library/mac/documentation/General/Reference/InfoPlistKeyReference/Articles/CocoaKeys.html)
- [Core Foundation Keys](https://developer.apple.com/library/mac/documentation/General/Reference/InfoPlistKeyReference/Articles/CoreFoundationKeys.html#//apple_ref/doc/uid/TP40009249-SW1)

## 宏NSLocalizedString
```
#define NSLocalizedString(key, comment) \
	    [[NSBundle mainBundle] localizedStringForKey:(key) value:@"" table:nil]
```

具体调用的是  
![](https://farm3.staticflickr.com/2948/15200925349_de5d0e324f_o.png)

可以看到`table`传参`nil`，其实就是指定了默认的本地化文件`Localizable.strings`。

## 本地化注意问题
1. 注意`.strings`文件的选择
2. `.strings`中重复的key会导致只取第一个匹配
3. 格式`  key = value ; ` 注意最后的冒号，不加编译不过

-以上-
