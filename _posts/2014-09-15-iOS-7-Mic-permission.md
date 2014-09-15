---
layout: post
title: iOS 7 系统麦克风请求权限
date: 2014-09-15     T
meta: ture
---

在iOS 6以后对应用使用一些系统功能做了权限控制，如获取位置，获取相册，调用mic...

所以在使用这些功能上需要先向用户请求权限，等用户同意后才能继续操作。

在请求权限时会弹一个UIAlert（如图），  

Flickr   
![](https://farm4.staticflickr.com/3910/15061447188_7251995348_z.jpg)
  
  
微信  
![](https://farm6.staticflickr.com/5575/15224997626_1b002a2216.jpg)
这会影响某些操作，如实现如微信的Hold to Talk时，在iOS7以上第一次只能做权限请求，第二次才能开始真正的Hold to Talk。

### Mic权限相关代码
```
- (void)requestRecordPermission:(PermissionBlock)response NS_AVAILABLE_IOS(7_0);
```

贴上代码，用一个BOOL值去控制 UIAlertView点OK后是否执行Block

```
+ (void)checkMicrophonePermissionAndRunAction:(void (^)(void))action runActAfterAlert:(BOOL)bRun {
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    // if on iOS 7 or later there will be a UIAlertView
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession requestRecordPermission:^(BOOL granted) {
            if (granted) {
            	// UIAlertView OK button Tapped
                // Microphone enabled code
                if (bRun && action) {
                    action();
                }
            }
            else {
                // Microphone disabled code
                
                // We're in a background thread here, so jump to main thread to do UI work.
                dispatch_async(dispatch_get_main_queue(), ^{
                    [[[UIAlertView alloc] initWithTitle:@"Microphone Access Denied"
                                                message:@"This app requires access to your device's Microphone.\n\nPlease enable Microphone access for this app in Settings / Privacy / Microphone"
                                               delegate:nil
                                      cancelButtonTitle:@"Dismiss"
                                      otherButtonTitles:nil] show];
                });
            }
        }];
    }
    else {
        if (action) {
            action();
        }
    }
}

```


-以上-
