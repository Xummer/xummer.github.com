---
layout: post
title: "iOS 越狱开发环境搭建"
date: 2013-07-09 22:13:52
meta: ture
---
iOS7 beta 3今天出了，除了系统的 icon 比较难看之外其他 UI 个人还是蛮喜欢的。  

一直在做 iOS 开发一直没有接触过 JailBreak 开发，最近看了[碳基体](http://danqingdani.blog.163.com/) 的一些文章后开始对 iOS 安全产生兴趣。网上找了下资料，基本都是 2010-11 年左右的资料，具体有一些细小的设置已经不同了。所以写一篇 blog，权当做记录。「很多东西不用就会忘记，一段时间后又要用，无疑又重新增加了学习成本」就像最新一期的 macTalk 中说的 『通晓天下武功而百无一用，其实和不出家门的书生也没太大区别；学尽世上技术但做不出成功的产品，一样是 Meaningless，所谓知行合一，实在缺一不可！』  
  
## 环境选择
JB 环境选择了 [@DHowett](http://twitter.com/dhowett) 编写的 [Theos](http://iphonedevwiki.net/index.php/Theos/Getting_Started) 后来发现还有一个 [iOSOpenDev](http://iosopendev.com/download/)，算是一个 Xcode 的插件，直接下载一个 pkg 文件，无脑安装就好，稍微要注意下的就是安装中的报错，按照这上面来做就搞定了 [安装问题解决方法](https://github.com/kokoabim/iOSOpenDev/wiki/Troubleshoot)。还是相当简单快捷的。  
  
## 参考资料
主要是这篇 [Beginning Jailbroken iOS Development – Getting The Tools](http://brandontreb.com/beginning-jailbroken-ios-development-getting-the-tools) 虽然是英文，但是写的还是很简单易懂的(我的渣英文不 google 也能懂，甚是欣慰)。虽然 Theos 也支持 linux，但是这篇文章主要是对 mac 来配置的，linux 可以 google 的其他文档。  
  
## Setp 1: Install the iOS SDK
安装 iOS SDK。作为 iOS 开发这个必须有。没有的话下个 Xcode 就有了 或者去 apple developer 官网下 [http://developer.apple.com/devcenter/ios/index.action](http://developer.apple.com/devcenter/ios/index.action)。

## Step 2: Setting Up The Environment Variables
配置临时环境变量(为什么叫临时环境变量，玩过 linux 或 unix shell 的朋友应该都了解，在一个 terminal 中 export 的环境变量是临时的，如果你关掉并重新开一个 terminal，这个变量就消失了，你在新的 terminal 中无法使用这个环境变量了。)设置 theos 的路径，设为 `/opt/theos`    

```bash
$ export THEOS=/opt/theos
```  

## Step 3: Getting theos
从 github 上获取 theos 的源码到上面所设置的路径。	  

```bash
$ sudo git clone https://github.com/DHowett/theos $THEOS
```
  
## Step 4: Getting ldid
获取 ldid。ldid 是一个签名工具能让你所编写的程序在越狱后的 iOS 设备上运行。这 dropbox 中的这货需要梯子，大天朝你懂的，我这有下好的 [ldid](http://pan.baidu.com/share/link?shareid=2373296890&uk=2885859734), 虽然不用百度搜索，但是百度网盘在墙内还是很好的分享工具。下完之后执行从 `chmod` 开始的命令就可。    

```bash
curl -s http://dl.dropbox.com/u/3157793/ldid > ~/Desktop/ldid
chmod +x ~/Desktop/ldid
sudo mv ~/Desktop/ldid $THEOS/bin/ldid
```
  
## Step 5: Install dpkg
安装 `dpkg` 基于 debian 的包管理软件。Mac 下可以用 Fink, Macport 或 homebrew [三者的比较](http://tetsu.iteye.com/blog/1507524)。网上都是装 Macport, 我之前装了 homebrew, 所以直接用 [homebrew](http://mxcl.github.io/homebrew/)    

```bash
$ brew install dpkg
```  

再说下 Mac 下的 dpkg，dpkg -i 并不能将 xx.deb 安装到 mac， mac 不支持 debian 的包，如果只是要解压 deb 包的话，也可以不装 dpkg 只需要用` ar -x xxx.deb` 就欧了。  
  
-先写到这，未完待续-
