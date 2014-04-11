---
layout: post
title: 从web安装ipa
date: 2013-08-29 22:49:26
meta: ture
---
最近都用企业版证书发布ipa，不用上appstore，不用审核也省了不少时间。记录下具体的网页安装ipa的方法，不只是企业版证书，越狱后的机器和加入开发组有匹配profile的测试机器,也可以通过这种方式来安装ipa。
  

##Apple官方文档
[传送门](http://help.apple.com/iosdeployment-apps/mac/1.1/#app43ad871e)
##准备
总共需要准备3样东西，ipa、html和plist。

###0.Web Server
首先你要有个web Server，这不是本文的重点，MAC下推荐[MAMP](https://www.mamp.info/en/) 一键安装省去各种折腾。

###1.ipa
这个是必须的，不解释。注意，ipa名字不能为中文，中文会导致下载不了。

###2.html
   
```html   
<html>
	<body>
		<a href="itms-services://?action=download-manifest&url=http://192.168.16.201/appdownload/app.plist">click to download </a>
	</body>
</html>
```   
   
###3.plist
需要修改ipa具体的路径和bundle identifier(见下图)，其他可改可不改。  

![](/images/blog-images/2013-08-29/ipaWebDownloadPlist.png)  
	   
[app.plist 下载地址](http://pan.baidu.com/share/link?shareid=698052472&uk=2885859734)

###4.目录结构

把着3个文件和icon(可不加)，丢到同级目录下。之后用iOS设备访问该网页，点击`click to download`，就能安装了。

```
▾ appdownload/                                                                  
    SAO.ipa
    app.plist
    icon.png
    index.html
```

---
* 2014-01-21  
iOS7 如此安装会留下一个久的空壳App，无法删除（若要删除要恢复出厂设置，2333）。 iOS7以下没有这个问题。推测是由于修改.plist的bundleID导致iOS设备没有识别到新的bundleID，新建一个.plist文件就可以了。
[OS传送门](http://stackoverflow.com/questions/19423742/installing-in-house-apps-stuck-looping-on-ios-7)。

* 2014-03-24  
[iOS7.1下需要https部署的解决方案](http://beyondvincent.com/blog/2014/03/17/five-tips-for-using-self-signed-ssl-certificates-with-ios/)
  

「以上」
