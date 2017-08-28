---
layout: post
title: 在 Xcode 8 上创建 iOS Framework
date: 2017-08-28     T
meta: ture
---

本文中主要包含:
1. 如何创建 Universal Framework;
2. Static Framework 和 Dynamic Framework 的区别;
3. 如何不在符号表文件中显示代码文件的具体路径;

## 创建 Framework
主要参考自[Build a custom universal framework on iOS swift](https://medium.com/swiftindia/build-a-custom-universal-framework-on-ios-swift-549c084de7c8)

### 1.创建 Cocoa Framework
Xcode 中 File → New → Project

![](https://ws1.sinaimg.cn/large/006tKfTcgy1fiz8a4ez1zj314s0tiwjc.jpg)

之后一路 next.

### 2.开启 bitcode

Target → Project Name → Build Settings → Build Option 中确认 Enable Bitcode 设置为 Yes.

![](https://ws3.sinaimg.cn/large/006tKfTcgy1fiz8ekzyvij30vq0bu0uz.jpg)

### 3.创建 Universal framework

单独运行生存的 Framework 只能支持一个单独的架构（如 i386, arm v7s 等），可以通过 `lipo` 命令来合成多个架构的 fat binary，但是手动合成效率太低，可以通过一个脚本来合成。

选中 Project Target → Edit Schema → Archive → Post-actions → 点击 “+” 号 → New Run Script Action.

![](https://ws3.sinaimg.cn/large/006tKfTcgy1fiz92gdikej30g20mygn3.jpg)

具体脚本如下

```bash
UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal
# Make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"
# Next, work out if we're in SIM or DEVICE
xcodebuild -target "${PROJECT_NAME}" -configuration ${CONFIGURATION} -sdk iphonesimulator ONLY_ACTIVE_ARCH=NO BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build
xcodebuild -target "${PROJECT_NAME}" ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}" clean build
# Step 2. Copy the framework structure (from iphoneos build) to the universal folder
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework" "${UNIVERSAL_OUTPUTFOLDER}/"
# Step 3. Copy Swift modules from iphonesimulator build (if it exists) to the copied framework directory
BUILD_PRODUCTS="${SYMROOT}/../../../../Products"
cp -R "${BUILD_PRODUCTS}/Debug-iphonesimulator/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule/." "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/Modules/${PROJECT_NAME}.swiftmodule"
# Step 4. Create universal binary file using lipo and place the combined executable in the copied framework directory
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_PRODUCTS}/Debug-iphonesimulator/${PROJECT_NAME}.framework/${PROJECT_NAME}" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/${PROJECT_NAME}.framework/${PROJECT_NAME}"
# Step 5. Convenience step to copy the framework to the project's directory
cp -R "${UNIVERSAL_OUTPUTFOLDER}/${PROJECT_NAME}.framework" "${PROJECT_DIR}"
# Step 6. Convenience step to open the project's directory in Finder
open "${PROJECT_DIR}"
fi
```

现在在每次 Archive 时就能直接生成 Universal Framework.



## 配置
### 1.静态库和动态库
`Build Settings → Linking → Mach-O Type` 中有多个选项，创建完默认是 `Dynamic Library`

![](https://ws2.sinaimg.cn/large/006tKfTcgy1fiw3vb4ic7j30v20j4adt.jpg)

Dynamic Library 和 Static Library 的区别:
#### a. 集成时配置
`Static Library` 只需要将 Framework 拖到项目中, 保证勾选 Copy item if needed 和 Create groups 以及对应 Targets;

![](https://ws1.sinaimg.cn/large/006tKfTcgy1fiw4w70qq6j30po0a23zq.jpg)

`Dynamic Library` 需要和 Static Library 相同的操作以及需要添加 Embedded Binaries

![](https://ws3.sinaimg.cn/large/006tKfTcgy1fiw4y9h2o3j30xe0gkt9t.jpg)

#### b. 打包成 ipa 时
`Dynamic Library` 会单独生成和 Framework 名对应的 Framework 目录，添加的 Framework 会在该目录下；

![](https://ws1.sinaimg.cn/large/006tKfTcgy1fiw3y3vv49j30mq05074w.jpg)

`Static Library` 会将自身合并到可执行的 Mach-O 文件里，并不生成 Framework 目录；

![](https://ws3.sinaimg.cn/large/006tKfTcgy1fiw40cj7vij30bm0480sz.jpg)

### 2.消除符号表中文件路径

如果在打包 ipa 时勾选了 `Include app symbols for your application to receive symbolicated reports from Apple`.

![](https://ws1.sinaimg.cn/large/006tKfTcgy1fiw4b5a8mnj30u60cqmym.jpg)

你将会在生成的 ipa 包里找到符号表文件 xxxx.bcsymbolmap 或者 xxxx.symbols (未开启bitcode)

![](https://ws2.sinaimg.cn/large/006tKfTcgy1fiw48pkugyj30mu03adgd.jpg)

![](https://ws4.sinaimg.cn/large/006tKfTcgy1fiw4femsamj30mk05sgms.jpg)

在里面你能找到你的 Framework 中每个文件的路径（如下图）。

![](https://ws4.sinaimg.cn/large/006tKfTcgy1fiw4hqi120j30ju03kwf1.jpg)

如何取消？
`Generate Debug Symbols` 设置为 NO;

![](https://ws3.sinaimg.cn/large/006tKfTcgy1fiw46ajbvzj30qs0c4mzc.jpg)

## 参考链接
1. [Build a custom universal framework on iOS swift-Medium](https://medium.com/swiftindia/build-a-custom-universal-framework-on-ios-swift-549c084de7c8)
2. [How to avoid symbols and source paths in iOS binary? SO](https://stackoverflow.com/questions/8167893/how-to-avoid-symbols-and-source-paths-in-ios-binary)




-以上-


