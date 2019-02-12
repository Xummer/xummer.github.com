---
layout: post
title: iOS App 中拨打电话
date: 2014-10-28     T
meta: ture
---

## 问题

实现 app 中拨打电话后返回 app，通过 load 一个 webview 来实现。（单纯的拨打电话直接 `openUrl` 就可以解决。）

之前网上盛行的代码

```
NSString *phoneStr = [NSString stringWithFormat:@"tel://%@“, phone];
UIWebView *callWebview = [[UIWebView alloc] init];
NSURL *telURL = [[NSURL alloc] initWithString:phoneStr];
[callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
[[[UIApplication sharedApplication] keyWindow] addSubview:callWebview];
```

UrlSchema | 是否有效 
--- | --- 
`tel:15121002014` | 有效
`tel:+8615121002014` | 无效
`tel:(+86)15121002014` | 无效
`tel:1 512 100 2014` | 无效
`tel:1-512-100-2014` | 无效

## 解决方法

之前没有公开 `tel` 这个 url schema, 现在已经有了 [Apple文档](https://developer.apple.com/library/ios/featuredarticles/iPhoneURLScheme_Reference/PhoneLinks/PhoneLinks.html) ，主要改变有以下两点。  

1. 用 `tel:` 代替之前的 `tel://` （原来的加双斜杠没有问题，还是按照文档上写的）   
2. 用 `NSString` 的 [stringByAddingPercentEscapesUsingEncoding](https://developer.apple.com/library/ios/documentation/Cocoa/Reference/Foundation/Classes/NSString_Class/index.html#//apple_ref/occ/instm/NSString/stringByAddingPercentEscapesUsingEncoding:) 规则化电话格式

```
NSString *originalPhone =  [phone stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
NSString *phoneStr = [NSString stringWithFormat:@"tel:%@", originalPhone];
UIWebView *callWebview = [[UIWebView alloc] init];
NSURL *telURL = [[NSURL alloc] initWithString:phoneStr];
[callWebview loadRequest:[NSURLRequest requestWithURL:telURL]];
[[[UIApplication sharedApplication] keyWindow] addSubview:callWebview];
```

UrlSchema | 是否有效 
--- | --- 
`tel:15121002014` | 有效
`tel:+8615121002014` | 有效
`tel:(+86)15121002014` | 有效
`tel:1 512 100 2014` | 有效
`tel:1-512-100-2014` | 有效

-以上-
