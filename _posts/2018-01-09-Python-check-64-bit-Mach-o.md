---
layout: post
title: Python 检测 64 位 Mach-o
date: 2018-01-09     T
meta: ture
---

为什么会有这篇文章，也许你会说 Mac 命令行之间 `file` 命令就可以知道，何必再去造一个？
原因有两个：
1. `file` 无法正确识别某些 C++ 打包的游戏，这些游戏 Mach-o 的 Header 中标识了本 Mach-o 文件只有一个架构的，`file` 命令也就很老实地只去读了第一个，导致结果只有一个架构的；（然而 AppleStore 能正确识别这些包 😂）
2. `file` 只有在 Mac 上能使用，Linux 没有该命令也没有类似的命令，而大部分服务器都是 Linux；

Talk is cheap， show you the code！

[Gist](https://gist.github.com/Xummer/088770eb01cbcc30316bd0eef8fbf986)

```python
# -*- coding: utf-8 -*- 
import os,sys

def checkMachO(path):
	# print path
	is_path_exists = os.path.exists(path)
	if is_path_exists:
		with open(path, 'rb') as f:
			headMagic = ""
			for i in range(0, 4):
				s = f.read(1)
				byte = ord(s)
				headMagic = headMagic + hex(byte)[2:]
				# print hex(byte)
			pass
			# fat:0xbebafeca 32: 0xfeedface 64: 0xfeedfacf
			# print headMagic
			if headMagic == "cafebabe":
				# Is Fat Mach-o
				# Jump 3
				f.read(3)

				t = f.read(1)
				archiveCount = ord(t)

				# Jump 8
				f.read(8)

				# print archiveCount
				arrOffsets = []
				offsetDelta = 0
				# for i in range(0, archiveCount):
				while 1:
					offset = 0
					for j in range(0, 4):
						r = f.read(1)
						# print ord(r)
						offset = offset + ord(r) * (256 ** (3-j))

					if offset == 0:
						offsetDelta = 4
						break;

					arrOffsets.append(offset)
					# print offset
					# Jump 16
					f.read(16)
				pass
				# currentOffset = 0x10 + archiveCount * 20
				currentOffset = 0x10 + len(arrOffsets) * 20 + offsetDelta

				msg = ""
				is_32bit = 0
				is_64bit = 0

				# print arrOffsets
				for of in arrOffsets: 
					delta = of - currentOffset
					f.read(delta)
					magic = ""
					for i in range(0, 4):
						s = f.read(1)
						byte = ord(s)
						magic = magic + hex(byte)[2:]
					pass

					# ap = ""
					# if len(msg) > 0:
					# 	ap = "&"
					# 	pass
						
					# print magic
					if is_64bit == 0 and magic == "cffaedfe":
						is_64bit = 1
						# msg = msg + ap + "arm64" 
						# print "arm64"
					else:
						if is_32bit == 0 and magic == "cefaedfe":
							is_32bit = 1
							# msg = msg + ap + "arm32" 
							# print "arm32"
					currentOffset = of + 4

				if is_32bit == 1 and is_64bit == 1:
					print "arm32&arm64"
				else:
					if is_32bit == 1:
						print "arm32"
					else:
						if is_64bit == 1:
							print "arm64"
							pass
						pass

				# print msg
			else:
				if headMagic == "cffaedfe":
					print "arm64"
					pass
				else:
					if headMagic == "cefaedfe":
						print "arm32"
						pass
				pass
		pass
	pass

if __name__ == '__main__':
	checkMachO(sys.argv[1])
```

PS: 贴一个 `file` 无法正确识别的 [ipa 地址](https://itunes.apple.com/cn/app/%E4%B8%AD%E5%9B%BD%E8%B1%A1%E6%A3%8B/id504275369?l=en&mt=8)，有兴趣的可以自己下下来试试。

-以上-
