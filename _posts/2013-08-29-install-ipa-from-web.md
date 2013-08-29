---
layout: post
title: 从web安装ipa
date: 2013-08-29 22:49:26
meta: ture
---
最近都用企业版证书发布ipa，不用上appstore，不用审核也省了不少时间。记录下具体的网页安装ipa的方法，不只是企业版证书，越狱后的机器也可以通过这种方式来安装ipa。
  
##准备
总共需要准备3样东西，ipa、html和plist。

###1.ipa
这个是必须的，不解释。

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

![](/images/blog-images2013-08-29/ipaWebDownloadPlist.png)  
	   
[app.plist 下载地址](http://pan.baidu.com/share/link?shareid=698052472&uk=2885859734)
  

「以上」