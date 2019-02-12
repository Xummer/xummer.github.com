---
layout: post
title: "Cubieboard 安装 Debian"
date: 2013-05-13 22:46
meta: true
---
最近买了个 cubieboard 打算弄个 lnmp 折腾折腾。   
网上关于 cubieboard 的资料不是很多，不过花时间找一下也是有很好的文章的。本文中的折腾都是基于 [debian_wheezy_armhf_v1_mele.img](http://guillaumeplayground.net/share/debian_wheezy_armhf_v1_mele.img.gz)(MD5: ccdc08dd71bdd927f168b29fc2f8e83e).  
感谢大神提供img，<del>虽然还不清楚 img 的原理是什么 or2</del> [img](http://zh.wikipedia.org/zh/IMG%E6%A0%BC%E5%BC%8F)其实也就是一种归档格式，类似.iso。    

## 参考资料
下面就是我折腾中参考的资料：   
1.	[CubieBoard 开发板系统安装](http://blog.newhi.net/?post=31)       
--基本上各种命令都有列出。    
2.	[为 Cubieboard 打造完美 Debian 系统](http://www.enjoyself.net/index.php/archives/10.html)  
 --博主写的都比较清楚   
3.	[在 16G TF 卡安装 cubie-server-t4 镜像,使用全部可用空间](http://blog.sina.com.cn/s/blog_7c4badb70101cwnc.html)  
 --内容有用，排版有些乱，不过我也折腾了好久（大概是应为对 linux 命令不够熟吧 orz）  
4.	[Cubieboard 下安装配置优化LNMP环境](http://cb.e-fly.org/archives/23.html)    
-- 确实很nice  
5.	[安装 CubieBoard 最小系统 交叉编译](http://blog.newhi.net/?post=164)   
 --先码者，有时间再折腾

## Linux知识点
1. 解压 tar.gz
             
    ```bash
    $ tar -xzf  xxxx.tar.gz
    ``` 
    
2. 取消挂载
             
    ```bash
    $ umount /media/* 
    ```  

3. fdisk 分区  -- 具体可以看下[fdisk的使用](http://www.liusuping.com/ubuntu-linux/linux-fdisk-disk.html)
           
    ```bash
    $ fdisk /dev/mmcblk0 
    ```   
    
4. TF 卡识别  

    可能识别为：  
    **I**  硬盘格式  `/dev/sdb`    （用外接读卡器插 usb ）  
    **II** SD 卡格式 `/dev/mmcblk0` （直接插 pc 自带的 SD 卡读卡器）  
    两中分区分别为  
    `/dev/sdb1` 第一分区 `/dev/sdb2` 第二分区 ...  
    `/dev/mmcblk0p1` 第一分区 `/dev/mmcblk0p2` 第二分区 ...  

5. 查看 TF 卡信息   

    ```bash
    $ ls /dev/mmcblk0* 
    ```  
    输出：  
    >  /dev/mmcblk0 /dev/mmcblk0p1 

6. 查看 TF 卡分区

    ```bash  
    $ fdisk -l /dev/mmcblk0  
    ```
    也可以用  
    
    ```bash 
    $ fdisk  /dev/mmcblk0
    ```
    然后再输入 `p` 就可以了 退出时输入`q`（退出不保存）  
    输出：                      
    >   Disk /dev/mmcblk0: 15.9 GB, 15931539456 bytes  
    >   4 heads, 16 sectors/track, 486192 cylinders, total 31116288 sectors  
    >   Units = sectors of 1 * 512 = 512 bytes  
    >   Sector size (logical/physical): 512 bytes / 512 bytes  
    >   I/O size (minimum/optimal): 512 bytes / 512 bytes  
    >   Disk identifier: 0x00000000     
    >   
    >   Device Boot Start End Blocks Id System  
    >   /dev/mmcblk0p1 2048 34815 16384 c W95 FAT32 (LBA)  
    >   /dev/mmcblk0p2 34816 31116287 15540736 83 Linux     

7. 写入 img 到 TF 卡 
 
    ```bash
    $ dd if=<img 路径> of=/dev/<MMC_DEVICE> bs=1M
    ```             
    [MMC](http://zh.wikipedia.org/wiki/%E5%A4%9A%E5%AA%92%E9%AB%94%E8%A8%98%E6%86%B6%E5%8D%A1) _DEVICE 也就是 TF 卡的路径

8. 使 Debian 支持 1G 内存，并解决关机后无法按电源键开机启动的问题  
    将[sunxi-bootloader](http://www.enjoyself.net/usr/uploads/2013/05/Debian.zip)中的u-boot.bin 、sunxi-spl.bin文件写入到SD卡bootloader  
    
    ```bash
    $ dd if=sunxi-spl.bin of=/dev/mmcblk0 bs=1024 seek=8
    $ dd if=u-boot.bin of=/dev/mmcblk0 bs=1024 seek=32  
    ```
    在 cubieboard 中 可以用 `free -m` 来查看其上的内存

9. 用 img 刷写后调整 TF 卡剩余空间，使其全部可用  
    **需要输入的命令全部用 code标出，如：**
    
    ```
     /* 我是需要输入的命令 */
    ```  
    
    刷写 img 后在 linux 上操作 （需要 root 权限 或者（unbuntu）加 `sudo`）
      
    ```bash
    $ umount /media/*               // 解除所有挂载 
    $ fdisk /dev/mmcblk0            // 这里 /dev/mmcblk0 可能是 /$ dev/sdb 要看 TF 卡读出来是什么了 看第4点
    ```   	
    >   Command (m for help): 
    
    ```bash 
    	p         // 输入 p，列出磁盘目前的分区情况
    ```
    >   以下是我已经分好的数据 一开始刷写的没有31116287这么多，大概只有516287左右  
    >    Disk /dev/mmcblk0: 15.9 GB, 15931539456 bytes  
    >    4 heads, 16 sectors/track, 486192 cylinders, total 31116288 sectors  
    >    Units = sectors of 1 * 512 = 512 bytes  
    >    Sector size (logical/physical): 512 bytes / 512 bytes  
    >    I/O size (minimum/optimal): 512 bytes / 512 bytes  
    >    Disk identifier: 0x0003478c  
    >    Device Boot       Start              End             Blocks      Id    System
    >    /dev/mmcblk0p1      2048          30719         14336       c     W95 FAT32 (LBA)  
    >    /dev/mmcblk0p2    30720    31116287   15542784     83     Linux   
    >    Command (m for help):
       
    ```bash 
    	d         // 输入 d，然后选择分区，删除第2分区
    ```
    
    >   Partition number (1-4):
    
    ```bash
    	2
    ```
    
    >	Command (m for help):
    
    ```bash
    	p         // 输入 p，确认分区已经删除
    ```
    >   Disk /dev/mmcblk0: 15.9 GB, 15931539456 bytes  
    >   4 heads, 16 sectors/track, 486192 cylinders, total 31116288 sectors  
    >   Units = sectors of 1 * 512 = 512 bytes  
    >   Sector size (logical/physical): 512 bytes / 512 bytes  
    >   I/O size (minimum/optimal): 512 bytes / 512 bytes  
    >   Disk identifier: 0x0003478c  
    >   Device Boot       Start              End         Blocks      Id    System  
    >   /dev/mmcblk0p1      2048          30719         14336       c     W95 FAT32 (LBA)  
    >   Command (m for help):
     
    ```bash
    	n         // 输入 n，重建第2分区
    ```  
    >	Command action  
    >	e extended  
    >	p primary partition (1-4)
    
    ```bash
     	p			// 建立主分区
    ```
    > 	Partition number (1-4): 
    
    ```bash
    	2          // 分区号
    ```
    > First cylinder (30720-31116287, default 30720):  //分区起始位置  直接回车  
    > Using default value 30720  
    > Last cylinder or +size or +sizeM or +sizeK (30720-31116287, default 31116287):  //分区结束位置，单位为扇区  直接回车  
    > Using default value 31116287  
    > Command (m for help):  
    
    ```bash
    	p         // 输入p，确认第2分区已经分配
    ```
    
    >   Disk /dev/mmcblk0: 15.9 GB, 15931539456 bytes  
    >   4 heads, 16 sectors/track, 486192 cylinders, total 31116288 sectors  
    >   Units = sectors of 1 * 512 = 512 bytes  
    >   Sector size (logical/physical): 512 bytes / 512 bytes  
    >   I/O size (minimum/optimal): 512 bytes / 512 bytes  
    >   Disk identifier: 0x0003478c  
    >   Device Boot       Start              End         Blocks      Id    System  
    >   /dev/mmcblk0p1      2048          30719         14336       c     W95 FAT32 (LBA)  
    >   /dev/mmcblk0p2    30720    31116287   15542784     83     Linux
     
    ```bash
    e2fsck -f  /dev/mmcblk0p2      //检查第二分区
    resize2fs /dev/sdb2            //重新分配第二分区大小
    df -h                          //查看下当前的分区大小
    ```
 
 -以上-


 
  
