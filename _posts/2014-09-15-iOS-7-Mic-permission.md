---
layout: post
title: iOS 7 系统麦克风请求权限
date: 2014-09-15     T
meta: ture
---

### 权限问题

在iOS 6以后对应用使用一些系统功能做了权限控制，如获取位置，获取相册，调用mic...

所以在使用这些功能上需要先向用户请求权限，等用户同意后才能继续操作。

在请求权限时会弹一个 `UIAlertView`（如图），  

Flickr   
![](https://farm4.staticflickr.com/3910/15061447188_7251995348_z.jpg)
  
  
微信  
![](https://farm6.staticflickr.com/5575/15224997626_1b002a2216.jpg)   

这会影响某些操作，如实现如微信的 `Hold to Talk` 时，在iOS7以上第一次只能做权限请求，第二次才能开始真正的 `Hold to Talk`。

### Mic权限相关代码
```
/* Checks to see if calling process has permission to record audio.  The 'response' block will be called
 immediately if permission has already been granted or denied.  Otherwise, it presents a dialog to notify
 the user and allow them to choose, and calls the block once the UI has been dismissed.  'granted'
 indicates whether permission has been granted.
 */
typedef void (^PermissionBlock)(BOOL granted);

- (void)requestRecordPermission:(PermissionBlock)response NS_AVAILABLE_IOS(7_0);
```

### 解决方法

贴上代码：在检查获取到权限后调用Block

```
+ (void)checkMicrophonePermissionAndRunAction:(void (^)(void))action {
    
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    // if on iOS 7 or later there will be a UIAlertView
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession requestRecordPermission:^(BOOL granted) {
            if (granted) {
            	// 【1】
                // Microphone enabled code
                if (action) {
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

在代码【1】处   
每次调用Mic都需要检查权限，没法判断是否是 `UIAlertView` 点OK后执行，还是原来已经 granted, 所以需要在执行的 Block 里做点文章，去判断 `Hold to talk` 的 button 是否已经被放开。

```
- (void)onStartRecord:(id)sender {
    
    __weak typeof(self)weakSelf = self;
    void(^recordAction)(void) = ^(void) {
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        
        if (strongSelf.btnHoldToTalk.tracking && strongSelf.btnHoldToTalk.touchInside) {
            // Real Start Record
        }
    };
    
    [IBTAudioRecorder checkMicrophonePermissionAndRunAction:recordAction];
    
}
```

-以上-
