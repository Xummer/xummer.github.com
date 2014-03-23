---
layout: post
title: 命令行操作MySQL
date: 2014-03-17     T
meta: ture
---
###MySQL的折腾之旅
[MAMP](http://www.mamp.info/en/mamp-pro/)的MySQL, 不完全（之前的有提到）,无法安装[mysqldb](https://github.com/farcepest/mysqldb1). [MAMP中安装mysqldb不能 - 解决方法](http://dreamconception.com/tech/how-to-install-mysqldb-mysql-python-on-mamp/)未尝试。

后面看到[「再见MAMP，你好Ampps」](http://chriswiegman.com/2013/05/bye-bye-mamp-pro-hello-ampps/),直接换Ampps用了。

Ampps MySQL的root用户默认密码是mysql  
找到Ampps中的mysql路径`/Applications/AMPPS/mysql/bin`并将其加入环境变量

```
$ echo 'export PATH=/Applications/AMPPS/mysql/bin:$PATH' >> ~/.bash_profile
```
新开一个terminal窗口，

```
$ echo $PATH
```
看看有没加成功。然后就可以直接在terminal中使用mysql的命令了

```
which mysql
/Applications/AMPPS/mysql/bin/mysql
```

最后还是选择之前安装MySQL，绕了一圈又回到了原点。

以下是命令行操作MySQL的基础
---

###连接MySQL
```
$ mysql -u[MySQL用户名] -p[MySQL密码]
```
```
$ mysql -uroot -pmysql
Warning: Using a password on the command line interface can be insecure.
Welcome to the mysql monitor.  Commands end with ; or \g.
Your mysql connection id is 4697
Server version: 5.6.15 Source distribution

Copyright (c) 2000, 2013, Oracle and/or its affiliates. All rights reserved.

Oracle is a registered trademark of Oracle Corporation and/or its
affiliates. Other names may be trademarks of their respective
owners.

Type 'help;' or '\h' for help. Type '\c' to clear the current input statement.

```

下面的命令用'\h'或者RTFM(Read the Fucking Menu)都能找到，权当做个记录。

###查看当前所有用户
```
mysql> select host,user from mysql.user;
```
```
+-----------------+------+
| host            | user |
+-----------------+------+
| 127.0.0.1       | root |
| ::1             | root |
| JigarsMac.local | root |
| localhost       | root |
+-----------------+------+
4 rows in set (0.00 sec)
```


###创建新的用户
```
mysql> create user [新的用户名]@[登陆主机名] identified by '[新用户密码]';

```

创建名为`appadmin` 密码为`admin`的新用户

```
mysql> create user appadmin identified by 'admin';
Query OK, 0 rows affected (0.00 sec)
```

很奇怪`0 rows affected`,再看下当前所有用户

```
mysql> select host,user from mysql.user;
+-----------------+----------+
| host            | user     |
+-----------------+----------+
| %               | appadmin |
| 127.0.0.1       | root     |
| ::1             | root     |
| JigarsMac.local | root     |
| localhost       | root     |
+-----------------+----------+
5 rows in set (0.00 sec)
```

若要限制在固定地址登陆，比如localhost 登陆
```
mysql> create user appadmin@localhost identified by 'admin';
```

已经增加了`appadmin`。



###提升用户权限
```
mysql> grant [需要提升的权限] on [数据库名].* to [需要被提升权限的用户名]@[登陆主机名] identified by '[需要被提升权限的用户密码]';
```

「需要提升的权限」:

- all privileges 所有权限
- select
- insert
- update
- delete
select,insert,update,delete可自由组合

```
mysql> grant all privileges on test.* to appadmin identified by 'admin';

或者

mysql> grant all privileges on test.* to appadmin@localhost identified by 'admin';
```

###查看数据库们
```
mysql> show databases;
```
```
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
3 rows in set (0.00 sec)
```

###操作数据库
####创建

```
mysql> create database [数据库名];
```
```
mysql> create database test;
Query OK, 1 row affected (0.00 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
| test               |
+--------------------+
4 rows in set (0.01 sec)


```

####删除
```
mysql> drop database [数据库名];
```

```
mysql> drop database test;
Query OK, 0 rows affected (0.00 sec)

mysql> show databases;
+--------------------+
| Database           |
+--------------------+
| information_schema |
| mysql              |
| performance_schema |
+--------------------+
3 rows in set (0.00 sec)

```

####指定为当前数据库
```
mysql> use [数据库名]
```
```
mysql> use test
Database changed
```

####备份数据库（dump）
**!!注意!! 这不是mysql中执行的命令，而是Shell中执行的，看"$"符号**

```
$ mysqldump -u[MySQL用户名] -p [数据库名] > [导出sql文件路径 path/to/xx.sql]
Enter password:[输入数据库的密码]
```

####数据库导入
```
$ mysql -u[MySQL用户名] -p [数据库名] < [导入sql文件路径 path/to/xx.sql]
Enter password: [输入数据库的密码]
```

####查看表结构
```
mysql> desc plugin;
+-------+--------------+------+-----+---------+-------+
| Field | Type         | Null | Key | Default | Extra |
+-------+--------------+------+-----+---------+-------+
| name  | varchar(64)  | NO   | PRI |         |       |
| dl    | varchar(128) | NO   |     |         |       |
+-------+--------------+------+-----+---------+-------+
2 rows in set (0.00 sec)
```

```
mysql> show create table plugin;
+--------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| Table  | Create Table                                                                                                                                                                                   |
+--------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
| plugin | CREATE TABLE `plugin` (
  `name` varchar(64) NOT NULL DEFAULT '',
  `dl` varchar(128) NOT NULL DEFAULT '',
  PRIMARY KEY (`name`)
) ENGINE=MyISAM DEFAULT CHARSET=utf8 COMMENT='MySQL plugins' |
+--------+------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------+
1 row in set (0.00 sec)
```

###其他常用命令

####查看状态
```
mysql> show status;
```

输出好长

```
+-----------------------------------------------+-------------+
| Variable_name                                 | Value       |
+-----------------------------------------------+-------------+
| Aborted_clients                               | 0           |
| Aborted_connects                              | 13090       |
...
| Threads_running                               | 1           |
| Uptime                                        | 5783        |
| Uptime_since_flush_status                     | 5783        |
+-----------------------------------------------+-------------+
341 rows in set (0.00 sec)

```

####查看进程
```
mysql> show processlist;
```

```
+-------+------+-----------+------+---------+------+-------+------------------+
| Id    | User | Host      | db   | Command | Time | State | Info             |
+-------+------+-----------+------+---------+------+-------+------------------+
| 13086 | root | localhost | NULL | Query   |    0 | init  | show processlist |
+-------+------+-----------+------+---------+------+-------+------------------+
1 row in set (0.00 sec)
```

####Shell 命令

- mysqlshow 显示用户选择的数据库和表
                                                              
```
$ mysqlshow -uroot -p test
Enter password: 
Database: test
+--------+
| Tables |
+--------+
+--------+
```
- mysqladmin 创建和维护MySQL数据库的命令

###MySQL SQL语句
####Top
```
SELECT * FROM user 
WHERE department = "IT" 
LIMIT 1;
```

####事务
```
BEGIN;

SELECT * FROM user 
WHERE department = "IT" 
FOR UPDATE
LIMIT 1;

UPDATE user SET user_name = "Jobs" WHERE user_id = ? ;
 
COMMIT;
```

###MySQL中的锁
[MySQL锁，传送门](http://hedengcheng.com/?p=771#_Toc374698311)




-以上-
