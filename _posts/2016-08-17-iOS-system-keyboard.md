---
layout: post
title: iOS System KeyBoard 结构
date: 2016-08-17     T
meta: ture
---

![](http://ww2.sinaimg.cn/large/006tNbRwgw1f6wplrq56oj30g20gowfy.jpg)

![](http://ww2.sinaimg.cn/large/006tNbRwgw1f6wp0j27v9j305o06cjr9.jpg)

```
UITextEffectsWindow {(0, 0), (320, 480)}
- UIPeripheralHostView {(0, 0), (320, 216)}
|- UIKBInputBackdropView
||- UIKBBackdropView
|||- _UIBackdropEffectView
|||- UIView
|||- UIView
||- UIKeyboardAutomatic
|||- UIKeyboardImpl
||||- UIKeyboardLayoutStar
|||||- UIBBackgroundView
||||||- UIImageView 
|||||- UIKBKeyplaneView
||||||- UIKBSplitImageView [Hiden]
||||||- UIKBSplitImageView ㈠
|||||||- UIImageView 
||||||- UIKBSplitImageView ㈡
|||||||- UIImageView
||||||- UIKBKeyView ㈢ [123]    {(1, 173), (38, 42)}  
||||||- UIKBKeyView ㈣ [globel] {(41, 173), (38, 42)}
||||||- UIKBKeyView ㈤ [space]  {(113, 173), (126, 42)}
||||||- UIKBKeyView ㈥ [voice]  {(81, 173), (30, 42)}
||||||- UIKBKeyView ㈦ [Send]   {(241, 173), (78, 42)}
||||||- UIKBKeyView ㈧ [shift]  {(1, 119), (40, 42)}
||||||- UIKBKeyView ㈨ [delete] {(279, 119), (40, 42)}
||- MMInputAccessoryView {(0, 0), (320, 0)}
|- UIKBBlurredKeyView {(-3, 206), (102, 114)}
||- UIBBackdropView {(0, 0), (102, 114)}
|||- _UIBackdropEffectView
|||- UIView
|||- UIView ㈩
||- UIBKeyView ⑪ {(0, 0), (102, 114)}
```

![](http://ww1.sinaimg.cn/large/006tNbRwgw1f6wpja6nizj30gs06caa5.jpg)

```
|- UIKBBlurredKeyView {(41, 206), (302, 114)}
||- UIBBackdropView {(0, 0), (302, 114)}
|||- _UIBackdropEffectView
|||- UIView
|||- UIView ⑫
||- UIBKeyView ⑬ {(0, 0), (302, 114)}
```

## Previews

- UIKBInputBackdropView 
![](http://ww1.sinaimg.cn/large/006tNbRwgw1f6wny6ezdtj30hs0c0glg.jpg)

- UIKBKeyplaneView 
![](http://ww2.sinaimg.cn/large/006tNbRwgw1f6wnwkt5j5j30hs0c0756.jpg)
- UIKBSplitImageView ㈠ -> UIImageView 
![](http://ww2.sinaimg.cn/large/006tNbRwgw1f6wo1h0itqj30hs0c0q2x.jpg)
- UIKBSplitImageView ㈡ -> UIImageView 
![](http://ww2.sinaimg.cn/large/006tNbRwgw1f6wodsm51hj30hs0c074l.jpg)
- UIKBKeyView ㈢ 
![](http://ww1.sinaimg.cn/large/006tNbRwgw1f6woduxse2j302402cdfm.jpg)
- UIKBKeyView ㈣ 
![](http://ww2.sinaimg.cn/large/006tNbRwgw1f6wohmjvkmj302402ct8i.jpg)
- UIKBKeyView ㈤ 
![](http://ww1.sinaimg.cn/large/006tNbRwgw1f6wohsx0wvj307002cmwy.jpg)
- UIKBKeyView ㈥ 
![](http://ww4.sinaimg.cn/large/006tNbRwgw1f6wohyrfcoj301o02cdfl.jpg)
- UIKBKeyView ㈦ 
![](http://ww2.sinaimg.cn/large/006tNbRwgw1f6woi2z0wfj304c02ct8i.jpg)
- UIKBKeyView ㈧ 
![](http://ww1.sinaimg.cn/large/006tNbRwgw1f6woia1frhj302802c741.jpg)
- UIKBKeyView ㈨ 
![](http://ww2.sinaimg.cn/large/006tNbRwgw1f6woif44bzj302802cq2p.jpg)
- UIBBackdropView->UIView ㈩
![](http://ww2.sinaimg.cn/large/006tNbRwgw1f6wp4lrsakj305o06ca9u.jpg)
- UIKBBlurredKeyView->UIBKeyView ⑪ 
![](http://ww2.sinaimg.cn/large/006tNbRwgw1f6wp0j27v9j305o06cjr9.jpg)
- UIBBackdropView->UIView ⑫
![](http://ww4.sinaimg.cn/large/006tNbRwgw1f6wpj3waj1j30gs06cq2s.jpg)
- UIKBBlurredKeyView->UIBKeyView ⑬ 
![](http://ww1.sinaimg.cn/large/006tNbRwgw1f6wpja6nizj30gs06caa5.jpg)

-以上-


