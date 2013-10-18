---
layout: post
title: 从web安装ipa
date: 2013-08-29 22:49:26
meta: ture
---
最近都用企业版证书发布ipa，不用上appstore，不用审核也省了不少时间。记录下具体的网页安装ipa的方法，不只是企业版证书，越狱后的机器也可以通过这种方式来安装ipa。
  

##Apple官方文档
[传送门](http://help.apple.com/iosdeployment-apps/mac/1.1/#app43ad871e)
##准备
总共需要准备3样东西，ipa、html和plist。

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
  

「以上」
