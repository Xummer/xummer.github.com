---
layout: post
title: 用CFStringTransform实现汉字转拼音
date: 2014-04-14     T
meta: ture
---

很久之前，有做过iOS上的String转拼音，下了别人写的一个类库（就2文件` .h `和` .m `，但里面有几千行的代码），是把所有对应拼音的的文字输入到一个`NSDictionary`里，然后再匹配查找。输入是一个很大的工作量，然后还有几个没解决的问题  

* 无法区分多音字，一般找到第一个匹配的就`return`了,
* 无法正常显示声调，比如， 我 wo(3)

##CFString​Transform
最近看[NSHipster](http://nshipster.cn/cfstringtransform/)发现有这么一个`CFString​Transform`, 可以用于转换拼音。已经集成在` Core Foundation `里了(`coreFoundation -> CFString.h`)。大量的麻烦的事，Apple已经帮我们做好了，而且更为优雅，没有上面提到的那些问题(还是无法区分多音字，如 “视觉 睡觉” -> "shì jué shuì jué")。

```objc
Boolean CFStringTransform(
	CFMutableStringRef string, 
	CFRange *range, 
	CFStringRef transform, 
	Boolean reverse
);
```

>* string: 需要转换的字符串。由于这个参数是 CFMutableStringRef 类型，一个 NSMutableString 类型也可以通过自由桥接的方式传入。
* range: 转换操作作用的范围。这个参数是 CFRange，而不是 NSRange。
* transform: 需要应用的变换。这个参数使用了包含下面将提到的字符串常量的 [ICU transform string](http://userguide.icu-project.org/transforms/general)。
* reverse: 如有需要，是否返回反转过的变换。


transform具体可以参看[Apple文档](https://developer.apple.com/library/mac/documentation/corefoundation/Reference/CFMutableStringRef/Reference/reference.html#jumpTo_22)，贴下`CFString.h`里的 

```objc
/* Transform identifiers for CFStringTransform()
*/
CF_EXPORT const CFStringRef kCFStringTransformStripCombiningMarks;
CF_EXPORT const CFStringRef kCFStringTransformToLatin;
CF_EXPORT const CFStringRef kCFStringTransformFullwidthHalfwidth;
CF_EXPORT const CFStringRef kCFStringTransformLatinKatakana;
CF_EXPORT const CFStringRef kCFStringTransformLatinHiragana;
CF_EXPORT const CFStringRef kCFStringTransformHiraganaKatakana;
CF_EXPORT const CFStringRef kCFStringTransformMandarinLatin;
CF_EXPORT const CFStringRef kCFStringTransformLatinHangul;
CF_EXPORT const CFStringRef kCFStringTransformLatinArabic;
CF_EXPORT const CFStringRef kCFStringTransformLatinHebrew;
CF_EXPORT const CFStringRef kCFStringTransformLatinThai;
CF_EXPORT const CFStringRef kCFStringTransformLatinCyrillic;
CF_EXPORT const CFStringRef kCFStringTransformLatinGreek;
CF_EXPORT const CFStringRef kCFStringTransformToXMLHex;
CF_EXPORT const CFStringRef kCFStringTransformToUnicodeName;
CF_EXPORT const CFStringRef kCFStringTransformStripDiacritics CF_AVAILABLE(10_5, 2_0);
```

Transformation        			  	| Input           | Output
-----------------------------------|-----------------|--------
kCFStringTransformLatinArabic 	  	| mrḥbạ           | مرحبا 
kCFStringTransformLatinCyrillic  	| privet          | привет
kCFStringTransformLatinGreek 	  	| geiá sou        | γειά σου
kCFStringTransformLatinHangul	  	| annyeonghaseyo  | 안녕하세요
kCFStringTransformLatinHebrew	  	| şlwm            | שלום
kCFStringTransformLatinHiragana		| hiragana        | ひらがな
kCFStringTransformLatinKatakana		| katakana        | カタカナ
kCFStringTransformLatinThai		  	| s̄wạs̄dī          | สวัสดี
kCFStringTransformHiraganaKatakana	| にほんご         | ニホンゴ
kCFStringTransformMandarinLatin		| 中文		      | zhōng wén

例子  

```objc
NSMutableString *str = [@"恶魔之魂" mutableCopy];
CFMutableStringRef cfstr = (__bridge CFMutableStringRef)(str);
//CFRange strRange = CFRangeMake(0, str.length); //传 |Null| 表示所有都转换
CFStringTransform(cfstr, NULL, kCFStringTransformMandarinLatin, false);
NSLog(@"%@", str);
```

输出

```
è mó zhī hún
```




-以上-
