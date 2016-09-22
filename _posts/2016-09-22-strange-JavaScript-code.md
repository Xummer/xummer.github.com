---
layout: post
title: 一段奇怪的 JavaScript
date: 2016-09-22     T
meta: ture
---

## 问题
先上代码

```javascript
var dp = 0;
var L = 0;
if (dp > 0 && 1 != dp && (L = -1), 0 == isNaN(L) ) {
    alert(L);
}
else {
    alert("QAQ");
}
```

显示结果:

```javascript
L = 0;
```

把 `dp = 0.5;` 后再执行

```javascript
var dp = 0.5;
var L = 0;
if (dp > 0 && 1 != dp && (L = -1), 0 == isNaN(L) ) {
    alert(L);
}
else {
    alert("QAQ");
}
``` 

显示结果:

```javascript
L = -1;
```

## 解析

`if` 判断里有一个很奇怪的地方 `,` , 写了这么久的 `if` 没见过判断里带 `,` 的, 瞬间懵逼了. Google 下发现 [逗号操作符](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Operators/Comma_Operator) ; 
具体如下:

>### 概述
>
>**逗号操作符** 对它的每个操作对象求值（从左至右），然后返回最后一个操作对象的值。
>
>### 语法
>
>*expr1*, *expr2, expr3...*
>
>### 参数
>
>
>```javascript
expr1, expr2, expr3...
```
>
>任一表达式。
>
>
>
>### 描述
>
>当你想要在期望一个表达式的位置包含多个表达式时，可以使用逗号操作符。这个操作符最常用的一种情况是：`for` 循环中提供多个参数。
>
>### 示例
>
>假设 `a` 是一个二维数组，每一维度包含10个元素，则下面的代码使用逗号操作符一次递增/递减两个变量。需要注意的是，`var` 语句中的逗号***不是***逗号操作符，因为它不是存在于一个表达式中。尽管从实际效果来看，那个逗号同逗号运算符的表现很相似。但确切地说，它是 `var` 语句中的一个特殊符号，用于把多个变量声明结合成一个。下面的代码打印一个二维数组中斜线方向的元素：
>
>```javascript
for (var i = 0, j = 9; i <= 9; i++, j--)
  document.writeln("a[" + i + "][" + j + "] = " + a[i][j]);
```
>
>#### 处理之后返回
>
>另一个使用逗号操作符的例子是在返回值前处理一些操作。如同下面的代码，只有最后一个表达式被返回，其他的都只是被求值。
>
>```javascript
function myFunc () {
  var x = 0;
  return (x += 1, x); // the same of return ++x;
}
```

简单的来说就是 **逗号操作符** 
`expr1, expr2, expr3`, 
`expr1`,`expr2`,`expr3` 依次执行，最后返回最后一个 `expr3` 作为返回值;

写成代码:

```
expr1;
expr2;
return expr3;
```

所以之前的代码可以改成:

```javascript
var dp = 0;
var L = 0;
if (dp > 0 && 1 != dp) {
	L = -1;
}
if (0 == isNaN(L)) {
    alert(L);
}
else {
    alert("QAQ");
}
``` 

简单明了。


-以上-


