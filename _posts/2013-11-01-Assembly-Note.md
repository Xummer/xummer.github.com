---
layout: post
title: 汇编笔记
date: 2013-11-01 00:47:29
meta: ture
---

## 寻址方式

### 分类

* 1 立即寻址			
  mov eax, 56h   			; 常用于赋值
* 2 直接寻址	 		
  mov eax, [12345634] 		; 常用于处理变量
* 3 寄存器寻址		
  mov eax, [edi] 			; 常用于地址在寄存器中
* 4 寄存器相对寻址 	
  mov eax, [edi+32h] 		; 常用于访问数组和结构
* 5 基地址加变址寻址	
  mov eax, [ebp+esi]		; 常用于访问数组
* 6 相对基地址加变址寻址	
  mov eax, [ebx+edi-10h] ; 常用于访问结构
  
### 算数运算指令
#### add
加法指令，格式 “add oper1, oper2”。  
add 指令将 oper1 + oper2 的结果存放在 oper1 中。

```
add eax, esi					; 将 eax 寄存器的值加上 esi 寄存器的值，得出结果保存在 eax 寄存器中

add ebx, dword ptr [12345678]	; 将 ebx 寄存器的值加上内存地址为 12345678 所指的 4 字节值，
								; 得出的结果保存在 ebx 寄存器中，其中 dword ptr 的意思是
								; 显式说明按多少字节来操作
```

查看不同平台的 dword 所占用空间的大小，用 c 语言 `printf("%d", sizeof(DWORD));`。  
常见的还有 word ptr 和 byte ptr，表示按 word 来操作和 byte 来操作。

#### sub
减法指令，格式 “sub oper1, oper2”。  
sub 指令将 oper1 - oper2 结果存放在 oper1 中。

```
sub ecx, 4h						; 将 ecx 寄存器的值减去 4h，得出的结果保存在 eax 寄存器中

sub byte ptr[eax], ch			; 将内存地址为 eax 所指的数据按字节为单位和 ch 寄存器相减，
								; 得出的结果按字节为单位保存在 eax 所指的地方
```

#### inc
加 1 指令，格式 “inc oper”。  
inc 指令将操作数 oper 加 1，得出的结果保存在 oper 中。

```
inc eax							; 将 eax 寄存器的值加 1 ，得出的结果存放在原来的地方

inc word ptr[ebx+2]				; 将内存地址为 ebx+2 的数据按 word 为单位加 1 ，
							 	; 得出的结果存放在原来的地方
```

#### dec
减 1 指令，格式是 “dec oper”。  
dec 指令将操作是 oper 减 1，得出结果保存在 oper 中。

```
dec edx							; 将 edx 寄存器的值减 1 ，得出的结果存放在原来的地方

dec dword ptr [ebp+36]			; 将队长地址为 ebp+36 的数据按 dword 为单位减 1 ，
								; 得出的结果存放在原来的地方
```

#### cmp
比较指令，格式 “cmp oper1, oper2”。  
**cmp 指令将 oper1 减去 oper2，得出的结果不保存，只是相应的设置寄存器 EFLAGS 的 CF、PF、ZF、AF、SF 和 OF。也就是说可以通过测试寄存器的EFLAGS相关的标志的值得出 cmp 指令执行后的结果。**  

```
cmp eax, 56h					; 将 eax 寄存器的值减去 56h，得出的结果不保存，并且设置
								; 寄存器EFLAGS相关的标志值
								
cmp edx, dword ptr [ecx*2]		; 将 edx 寄存器的值以 dword 为单位减去内存地址为 ecx * 2
								; 所指的数据，得出的结果不保存，并且设置寄存器 EFLAGS 相关的标志值
```

#### neg
取补指令，格式 “neg oper”。  
neg 指令将 oper 操作数取反，简而言之糗事将零减去 oper 操作数，得出的结果保存在 oper 自身中。

在计算机的 CPU 中没有减法的机制，减法是用加法实现的，例如 100-55 这个操作，CPU 实际执行的是 100+(-55)，而 -55 相当于求 55 的相反数，求相反数的时候 neg 指令正好派上用场了。

```
neg eax							; 将 eax 寄存器的值取反，得出的结果保存在 eax 中

neg word ptr [12345678]			; 将内存地址为 12345678 所指的数据以 word 为单位取反，
								; 得出的结果以word为单位，保存在内存地址为 12345678 所指的地方
```

#### mul
无符号乘法指令，格式 “mul oper”。  
**mul 指令隐含了一个参加运算的操作数 eax 寄存器，mul 指令将 eax 寄存器的值乘以 oper，得出的结果在 eax 寄存器中。如果结果超过了 32 位，则高 32 位使用 edx 寄存器保存，eax 寄存器则保存低 32 位。**

```
mul edx							; 将 eax 寄存器的值乘以 edx 寄存器的值，得出的结果保存在 eax 寄存器中

mul byte ptr [edi]				; 将 eax 寄存器的值乘以以 byte 为单位的内存地址为 edi 所指的数据，
								; 得出结果保存在 eax 寄存器中
```

#### imul
有符号乘法指令，原理和操作同 mul，区别在于 imul 将参与运算的操作数当成有符号数来处理。  

#### div
除法指令，格式 “div oper”。  
**div 指令将 64 为（ EDX 和 EAX ）或 32 位（ EAX ）的值除以 oper，得出的商保存在 eax 寄存器中，而余数则保存在 edx 寄存器中，由 oper 操作数决定按多少字节操作。**

#### idiv
有符号除法指令，原理和操作同 div，却别在于 idiv 将参与运算的操作数当成有符号数来处理。  

### 逻辑运算指令
80x86 提供了 or、and、not、xor 和 test 这 5 条逻辑运算指令，逻辑运算指令和下面即将介绍的移位指令和下面即将介绍的移位指令相结合就是计算机数据加密/解密的基础，所以应该熟练掌握他们的用法。

#### or
或操作指令，格式 “or oper1, oper2”。  
or 指令将 oper1 操作数和 oper2 操作数进行或运算，得出的结果保存在 oper1 中。  

or 指令主要用于维持某个二进制数的默写位的值不变，而另一些位设置为 1 的情况。把不需要改变的位用 0 进行或运算，把要置为 1 的位用 1 进行或运算即可。

```
or eax, 80008000h				; 将 eax 寄存器和立即数 80008000h 进行或运算
								; 实际上是将 eax 寄存器的 32 位和 15 位置为1
								
or ah, bh						; 将 ah 寄存器和 bh 寄存器进行或运算
```

#### and
与操作指令，格式 “and oper1, oper2”。  
and 指令将 oper1 操作数和 oper2 操作数进行运算，得出的结果保存在 oper1 中。

and 指令主用用于位置某个二进制数的某些位置不变，而另一些位置置为 0 的情况。把不需要改变的位用 1 进行与运算，把要设置为 0 的位用 0 进行与运算即可。

```
and ch, 80h						; 将 ch 寄存器的值和 80h 进行与运算，实际上是将 ch 寄存器的第7位
								; 保持不变，其余位置0
				
and dword ptr [eax], 80008000h	; 将内存地址为 eax 所指的数据按 dword 为单位与 80008000h 进行与运算，
								; 实际上是将内存地址为 eax 所指的 4 字节数据的第 31 位和 15 位保持不变，
								; 其余位置为0
```

#### not
取反指令，格式 “not oper”。  
not 指令将 oper 操作数取反。主义 not 和 neg 不同，not 是按位取反，neg 是求补，求相反数，即用 0 减去操作数。  
例如  

```
    15H 的二进制为	0001 0101B
NEG 15H 的二进制为	1110 1011B = EBH
NOT 15H 的二进制为	1110 1010B = EAH

可见 求补=取反+1
```

#### xor
异或操作指令，格式 “xor oper1, oper2”。  
xor 指令将 oper1 操作数和 oper2 操作数进行异或运算，得出的结果保存到 oper1 中。

xor 指令主要用于位置某个二进制数的某些为的值不变，而某些为取反的情况。把不需要改变的位用 0 进行异或运算，把需要取反的为用 1 进行异或运算即可。

```
xor eax, ffff0000h				; 将 eax 寄存器的值和立即数 ffff0000h 进行异或运算，实际上是将
								; eax 寄存器的值的高 16 位取反，低 16 位保持不变
								
xor ah, f0f0h					; 将 ah 寄存器的值和立即数 8080h 进行异或运算，实际上是将 ah 寄存器的值的
								; 第 15 位和 7 位取反，其余位置保持不变
```

#### test
测试指令，格式 “test oper1, oper2”。  
test 指令是将 oper1 操作数和 oper2 操作数进行与运算，**不保存结构，只设置标志寄存器的 EFLAGS 相应的标志位的值。  
test 指令常用于测试一个二进制数的某些位是否为 1，但不改变操作数的情况。

```
test eax, f0000000h						; 将 eax 寄存器的值和立即数 f0000000h 进行与运算，
										; 实际上是测试 eax 寄存器的第 31、30、29、28位是否为1，
										; 并且设置标志寄存器的 EFLAGS 相应的标志位的值

test word ptr [edi*2], 10101010101010b	; 将内存地址为 edi*2 所指的数据按 word 为单位
										; 与 1010101010101010b进行与运算，实际上是按 word 为单位，
										; 测试内存地址为 edi*2 所指的数据的奇数位
										; 15、13、11、9、7、5、3 和 1 位的值是否为 1
```

### 移位指令
80x86 有 4 条普通的移位指令和 4 条循环的移位指令，他们都隐式的使用 **CF** 寄存器参与运算。

#### 普通移位指令
* sal：算数左移指令
* sar：算数右移指令
* shl：逻辑左移指令
* shr：逻辑右移指令

格式“普通移位指令 oper1, oper2”。  
其中 oper1 可以是寄存器或内存，oper2 代表的是移动的位数。其中 sal 指令和 shl 指令执行的结果是一样的。  
对于有符号和无符号书而言，sal 算数左移指令和 shl 逻辑左移指令每移动一位，相当于乘以 2。而 sar 算数右移指令和 shr 逻辑右移指令有点不同，对于有符号和无符号数而言，sar 算数右移指令每移动一位，相当于除以 2，而 shr 逻辑右移指令不管操作数是有符号数还是无符号数，每向右移动一位，左边都是以0填充，所以当操作数是无符号数的时候，shr 逻辑右移指令每移动一位才等于除以 2。

```
sal eax, 2						; 将 eax 寄存器的值向左移动 2 位，得出的结果保存在 eax 寄存器中，
								; 相当于 eax = eax x 4
								
sar dword ptr [esi], 4			; 将内存地址为 esi 所指的数据按 dword 为单位右移 4 位，
								; 相当于将内存地址为 esi 所指的数据按 dword 为单位的数据除以 16

shl dwird ptr [ebp+2h], 2		; 将堆栈地址为 ebp+2h 所指的数据按 dword 为单位左移 2位，
								; 相当于将堆栈地址为 ebp+2h 所指的数据按 dword 为单位的数据乘以 4

shr edi, ecx					; 将edi 寄存器的值逻辑右移ecx位
```

#### 循环移位指令
* rol：左循环移位指令
* ror：右循环移位指令
* rcl：带进位左循环移位指令
* rcr：带进位右循环移位指令

格式“循环移位指令 oper1, oper2”。  
其中 oper1 可以是寄存器或内存，oper2 要么是 CL 寄存器要么是 1，代表移动的次数，如果移动的次数多于 1 次，则需要把移动册数存放在 CL 寄存器中。  

rol、ror 和 rcl、rcr 的区别是见着没有将标志寄存器 EFLAGS 的 CF 进位标志包含参与循环移位，后者则把 CF 进位标志包含参与循环移位。

```
rol eax, 1						; 将 eax 寄存器的值向左移动一位，
								; 同时将被移除的位数放到最低位
								
ror eax, cl						; 将 eax 寄存器的值向右移动 cl 位，
								; 同时将被移除的位数放到最高位
								
rcl eax, 1						; 将 eax 寄存器的值向左移动一位，被移除的位送到 CF，
								; 同时将被移除的位数放到最低位
								
rcr eax, cl						; 将 eax 寄存器的值向右移动 cl 位，被移除的位送到 CF，
								; 同时将被移除的位数放到最高位
```

### 条件转移指令
程序结构可以分为 3 大部分，分别是顺序结构、分支结构和循环结构。像高级语言一样，在高级语言里有 if-else 条件分支、do-while 循环、for 循环和 goto 语句来改变程序执行流程。在汇编语言中没有高级语言里的 if-else 条件分支、do-while 循环、for 循环，汇编语言通过提供条件转移指令来实现程序执行流程的改变。  

#### 无条件转移指令 jmp
格式 “jmp oper”。  
其中 oper 是目的地址。

```
jmp eax							; 跳转到 eax 寄存器指示的 4 字节地址

jmp word ptr [esi*2]			; 跳转到内存地址为 esi*2 指示的 2 字节地址
```

#### 条件转移指令
汇编的条件转移指令非常多，通常可分为 3 大部分：无符号数的条件转移指令、有符号数的条件转移指令和算术条件转移指令。

格式：“条件转移指令名称 oper”。  
其中 oper 是目的地址。

##### 无符号数的条件转移指令
<table>
    <tbody>
        <tr>
            <td>指令名称</td>
            <td>转移条件</td>
            <td>转移说明</td>
        </tr>
        <tr>
            <td>ja / jnbe</td>
            <td>CF=0 且 ZF=0</td>
            <td>结果高于跳转 / 不低于等于跳转</td>
        </tr>
        <tr>
            <td>jae / hnb</td>
            <td>CF=0</td>
            <td>结果高于等于则跳转 / 不低于则跳转</td>
        </tr>
        <tr>
            <td>jb / jnae</td>
            <td>CF=1</td>
            <td>结果低于则跳转 / 不高于等于则跳转</td>
        </tr>
        <tr>
            <td>jbe / jna</td>
            <td>CF=1 或 AF=1</td>
            <td>结果低于等于则跳转 / 不高于则跳转</td>
        </tr>
    </tbody>
</table>

##### 有符号数的条件转移指令
<table>
    <tbody>
        <tr>
            <td>指令名称</td>
            <td>转移条件</td>
            <td>转移说明</td>
        </tr>
        <tr>
            <td>jg / jnle</td>
            <td>ZF=0 且 SF=OF</td>
            <td>结果大于则跳转 / 不小于等于则跳转</td>
        </tr>
        <tr>
            <td>jge / hnl</td>
            <td>SF=OF</td>
            <td>结果大于等于则跳转 / 不小于则跳转</td>
        </tr>
        <tr>
            <td>jl / jnge</td>
            <td>SF!=OF</td>
            <td>结果小于则跳转 / 不大于等于则跳转</td>
        </tr>
        <tr>
            <td>jle / jng</td>
            <td>ZF=1 或 SF!=OF</td>
            <td>结果小于等于则跳转 / 不大于则跳转</td>
        </tr>
    </tbody>
</table>

##### 算术条件转移指令
<table>
    <tbody>
        <tr>
            <td>指令名称</td>
            <td>转移条件</td>
            <td>转移说明</td>
        </tr>
        <tr>
            <td>jz / je</td>
            <td>ZF=1</td>
            <td>等于0则跳转 / 相等则跳转</td>
        </tr>
        <tr>
            <td>jnz / jne</td>
            <td>ZF=0</td>
            <td>不等于0则跳转 / 不相等则跳转</td>
        </tr>
        <tr>
            <td>js</td>
            <td>SF=1</td>
            <td>为负则跳转</td>
        </tr>
        <tr>
            <td>jns</td>
            <td>SF=0</td>
            <td>为正则跳转</td>
        </tr>
        <tr>
            <td>jo</td>
            <td>OF=1</td>
            <td>溢出则跳转</td>
        </tr>
        <tr>
            <td>jno</td>
            <td>OF=0</td>
            <td>不溢出则跳转</td>
        </tr>
        <tr>
            <td>jc</td>
            <td>CF=1</td>
            <td>进位标志被置则跳转</td>
        </tr>
        <tr>
            <td>jnc</td>
            <td>CF=0</td>
            <td>为正则跳转</td>
        </tr>
        <tr>
            <td>jns</td>
            <td>SF=0</td>
            <td>进位标志被清则跳转</td>
        </tr>
        <tr>
            <td>jp / jpe</td>
            <td>PF=1</td>
            <td>偶数则跳转</td>
        </tr>
        <tr>
            <td>jnp / jpo</td>
            <td>PF=0</td>
            <td>奇数则跳转</td>
        </tr>
    </tbody>
</table>

### 函数调用指令
在高级语言中，相信读者对函数在熟悉不过了，一个程序的功能可以认为是一组函数互相调用的结果，函数是计算并且返回某些值的一段代码。

在汇编语言中，使用 `call` 指令和 `ret` 指令或 `call` 指令和 `add esp, oper` 指令实现函数的调用与函数的返回。  
`call` 指令的格式是：`call oper`， 其中 oper 是函数地址。

`call` 指令首先将 esp 堆栈指针寄存器的值减 4，然后将 eip 程序指令奇数器的值压入堆栈，最后计算函数地址，将当前 eip 程序指令计数器的值置为函数地址。  
例如调用下面的 C 语言函数，计算机会执行如下操作:

```
							[	push	a[i]
							[	push	OFFSET string "%d"
	printf("%d", a[i]);   <		
							[	call	printf
							[	add		esp,8
```

在高级语言中调用函数时不需要编程人员管理堆栈和恢复函数调用前的环境，因为高级语言的编译器在编译源码的时候已经做好了。  
在汇编语言中，编程人员使用 `call` 调用完函数后需要使用 `ret` 指令或 `add esp` 指令恢复函数调用前的环境，以便调用完函数后程序能正常执行。  
`ret` 函数返回的格式是：`ret oper`,其中 oper 是需要从堆栈中pop出的字节数。  
`ret` 指令首先将堆栈中 pop 出 4 字节数据到 eip，然后 esp=esp+2，最后根据 oper 的值修改 esp 堆栈指针的值 esp=esp+oper。  
对于遵从 [Cdecl 调用约定](http://www.cppblog.com/oosky/archive/2007/01/08/17422.html) 的那些函数而言，函数调用完后不是使用 `ret` 指令，而是调用者使用 `add esp, oper` 从堆栈中弹出 oper 字节数据来清理堆栈。

### 函数调用约定
在 80x86 架构系统中，当一个函数有参数的时候，函数的参数传递很多时候需要利用堆栈来传递。那么从函数参数列表的左边向右边开始传递，还是从右边向左边传递呢？

#### 3种常用调用约定
调用约定是规定参数传递的顺序和堆栈平衡的方式。

* Pascal 调用约定   
  使用 Delphi、Kylix 编写的程序都遵循 Pascal 调用约定
* Cdecl 调用约定  
  C/C++/Java 编写的程序都遵循 Cdecl 调用约定
* StdCall 调用约定  
  Windows 的 API 调用遵循的是 StdCall 调用约定
  
```
Pascal 调用约定		 |	Cdecl 调用约定		  |	StdCall 调用约定		   |
--------------------------------------------------------------------- 
PUSH parameter1		|	PUSH parameter3		|	PUSH parameter3		|
PUSH parameter2		|	PUSH parameter2		|	PUSH parameter2		|
PUSH parameter3		|	PUSH parameter1		|	PUSH parameter1		|
CALL Message		|	CALL Message		|	CALL Message		|
 					|	ADD  ESP, 0CH		|						|
--------------------------------------------------------------------- 
参数从左到右传递，由	|	参数从右到左传递，		|	参数从右到左传递，由	|
被调用的函数清理堆栈	|	调用的函数清理堆栈		|	被调用的函数清理堆栈	|

```

### 字节码
假设内存中有字节码 53H，56H 和 57H，当这 3 个数作为数据处理的时候就表示 53H、56H 和 57H，当这 3 个 书作为治理处理的时候就表示 `push ebx`, `push esi`, `push edi`，那么到底一段字节码何时作为数据时候，何时作为指令执行呢。

#### 区块
* .test：常用于存放程序指令
* .rdata：常用于存放常量
* .data：常用于存放变量
* .idata：常用于存放 DLL 函数输入表
* .rsrc：常用于存放资源文件

真正执行时并不是通过区块名称来标识数据和指令的



