---
layout: post
title: iOS上创建静态库(static library)
date: 2014-04-09     T
meta: ture
---

##创建Static library
英文好的直接可以看这两个  
[Apple官方文档](https://developer.apple.com/library/ios/technotes/iOSStaticLibraries/Articles/creating.html)  
[Raywenderlich教程（貌似被 和™谐 了）](http://www.raywenderlich.com/41377/creating-a-static-library-in-ios-tutorial)

###创建新的Lib Target
![](../images/blog-images/2014-04-09/new_target.png)

![](../images/blog-images/2014-04-09/new_static_lib_0.png)

选`Cocoa Touch Static`一路next

![](../images/blog-images/2014-04-09/new_static_lib_1.png)

创建好之后你会有2个Xcode自动生成的文件在新的target中, 然后按照下图的要求把文件文件添加到`Build Phases`的子项下

* 需要编译的` .m `文件加到`Compile Sources`
* 需要被其他工程include的` .h `文件加到`Copy Files`

![](../images/blog-images/2014-04-09/compile_setting.png)

##### 编译标记

>`非arc`的` .m `加入到`arc`中  
`-fno-objc-arc`

>`arc`的` .m `加入到`非arc`中  
`-fobjc-arc`

![](../images/blog-images/2014-04-09/compile_flag.png)

###创建更为简单的Universal Lib

Aggregate Target是用于聚合多个target们的Target，我们可以用它来生成多个芯片架构的lib。

![](../images/blog-images/2014-04-09/aggregate_target.png)

添加run script

![](../images/blog-images/2014-04-09/run_script_0.png)

![](../images/blog-images/2014-04-09/run_script_1.png)

添加universal lib shell脚本

```
# define output folder environment variable
UNIVERSAL_OUTPUTFOLDER=${BUILD_DIR}/${CONFIGURATION}-universal
 
# Step 1. Build Device and Simulator versions
xcodebuild -target ImageFilters ONLY_ACTIVE_ARCH=NO -configuration ${CONFIGURATION} -sdk iphoneos  BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"
xcodebuild -target ImageFilters -configuration ${CONFIGURATION} -sdk iphonesimulator -arch i386 BUILD_DIR="${BUILD_DIR}" BUILD_ROOT="${BUILD_ROOT}"
 
# make sure the output directory exists
mkdir -p "${UNIVERSAL_OUTPUTFOLDER}"
 
# Step 2. Create universal binary file using lipo
lipo -create -output "${UNIVERSAL_OUTPUTFOLDER}/lib${PROJECT_NAME}.a" "${BUILD_DIR}/${CONFIGURATION}-iphoneos/lib${PROJECT_NAME}.a" "${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/lib${PROJECT_NAME}.a"
 
# Last touch. copy the header files. Just for convenience
cp -R "${BUILD_DIR}/${CONFIGURATION}-iphoneos/include" "${UNIVERSAL_OUTPUTFOLDER}/"
```

执行完后，点新生成的.a文件 Show in Finder，可以看到多了个文件夹Debug-universal，下面有一个合并好的fat lib

![](../images/blog-images/2014-04-09/lib_show_in_finder.png)

![](../images/blog-images/2014-04-09/universal_lib.png)

![](../images/blog-images/2014-04-09/lipo_info_fat_lib.png)

##创建bundle
用于存放图片资源以及nib（xib）文件。

只有mac下有bundle

![](../images/blog-images/2014-04-09/bundle_0.png)

新建一个会多一些mac的类库，删除就好

![](../images/blog-images/2014-04-09/bundle_1.png)

把需要的资源文件加到bundle的`Copy Files`中。

如果`nib`中有引用图片的，默认是在和`nib`同一个`bundle`下找。

[IB或代码设置读取其他`bundle`的图片](http://stackoverflow.com/questions/7733565/ios-how-to-use-images-in-custom-bundle-in-interface-builder)

```
myImageView.image = [UIImage imageNamed:@"MyBundle.bundle/picture1.png"];
```


##Category in static library

如果lib中有使用`Category`,在导入其他工程后会报错，找不到`Category`的方法。

```
+[UIImage libImageNamed:]: unrecognized selector sent to class 0x3982df88
```

添加`Other Linker Flags`: `-ObjC`

![](../images/blog-images/2014-04-09/other_linker_flag.png)

具体-ObjC表示的含义[SO](http://stackoverflow.com/questions/2567498/objective-c-categories-in-static-library)

>`-all_load` Loads all members of static archive libraries.

>`-ObjC` Loads all members of static archive libraries that implement an Objective-C class or category.

>`-force_load (path_to_archive)` Loads all members of the specified static archive library. Note: -all_load forces all members of all archives to be loaded. This option allows you to target a specific archive.

几个好用的`category`
[UIImage+bundle](https://github.com/AliSoftware/Xcode-Utils/blob/master/LibraryWithRsrc/Demo/Demo2Lib/Classes/UIImage%2BBundle.m)

-以上-
