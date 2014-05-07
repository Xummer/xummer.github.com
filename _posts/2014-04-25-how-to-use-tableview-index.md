---
layout: post
title: 使用UITableView右侧索引
date: 2014-04-25     T
meta: ture
---

# UITableView 右侧索引

UITableView 自带索引，一直和他打交道，但却一直没用过。

## 如何使用

[Github 传送门](https://github.com/Xummer/TableViewIndexDemo)

### 1. 实现TableView, （过于简单，略过）

### 2. 创建两个`property `

```
@property (strong, nonatomic) NSArray *contacts;    // 存放排序后的内容
@property (strong, nonatomic) NSArray *indexList;   //  存放右侧索引
```

### 3. 创建联系人的数据模型

```
// === .h ===

#import <Foundation/Foundation.h>

@interface ContactEntity : NSObject

@property (strong, nonatomic) NSString *avatarUrl;
@property (strong, nonatomic) NSString *name;

@end

// === .m ===

#import "ContactEntity.h"

@implementation JTContactEntity


@end

```

### 4.  重写contacts的setter方法

```
- (void)setContacts:(NSArray *)objects {
    _contacts = [self arrayForSections:objects];
    [_tableView reloadData];
}
```
#### 关键是用`UILocalizedIndexedCollation`来做分组和排序

```
- (NSArray *)arrayForSections:(NSArray *)objects {
    /* 
     * selector 需要返回一个 NSString ，按照这个返回的string来做分组排序，
     * | name | 是 | ContactEntity | 的Propty，直接有get方法
     */
    SEL selector = @selector(name);
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];

    // | sectionTitlesCount | 的值为 27 , | sectionTitles | 的内容为 A - Z + #，总计27，（不同的Locale会返回不同的值，见http://nshipster.com/uilocalizedindexedcollation/）
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    
    // 创建 27 个 section 的内容
    NSMutableArray *mutableSections = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        [mutableSections addObject:[NSMutableArray array]];
    }
    
    // 将| objects |中的内容加入到 创建的 27个section中
    for (id object in objects) {
        NSInteger sectionNumber = [collation sectionForObject:object collationStringSelector:selector];
        [[mutableSections objectAtIndex:sectionNumber] addObject:object];
    }
    
    for (NSUInteger idx = 0; idx < sectionTitlesCount; idx++) {
        NSArray *objectsForSection = [mutableSections objectAtIndex:idx];
        [mutableSections replaceObjectAtIndex:idx withObject:[[UILocalizedIndexedCollation currentCollation] sortedArrayFromArray:objectsForSection collationStringSelector:selector]];
    }
    
    // 删除空的section
    NSMutableArray *existTitleSections = [NSMutableArray array];
    
    for (NSArray *section in mutableSections) {
        if ([section count] > 0) {
            [existTitleSections addObject:section];
        }
    }
    
    // 删除空section 对应的索引(index)
    
    NSMutableArray *existTitles = [NSMutableArray array];
    NSArray *allSections = [collation sectionIndexTitles];
    
    for (NSUInteger i = 0; i < [allSections count]; i++) {
        if ([mutableSections[ i ] count] > 0) {
            [existTitles addObject:allSections[ i ]];
        }
    }
    self.indexList = existTitles;
    
    return existTitleSections;
}

```

#### `existTitleSections `（也就是赋值后的_contacts）的结构

```
@[
	@[
		<ContactEntity: 0x9455c90>,
		<ContactEntity: 0x9459fc0>,
		<ContactEntity: 0x9454da0>
 	 ],
	@[
		<ContactEntity: 0x9459fd0>,
		<ContactEntity: 0x9459ff0>
	], …
]
```
#### `indexList`结构

```
<__NSArrayM 0x95265f0>(
A,
B,
D,
H,
N,
S,
T,
W,
Z,
#
)
```

### 5. 实现UITableViewDataSource

```
#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [_contacts count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [_contacts[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    JTContactsCell *cell =
    [tableView dequeueReusableCellWithIdentifier:contactsCellIdentifier
                                    forIndexPath:indexPath];
    [cell updateContent:_contacts[ indexPath.section ][ indexPath.row ]];
    return cell;
}

// 设置Section Header
- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return _indexList[ section ];
}

// 前几个都是常用的tableView Delegate
// 返回tableView右侧索引列表
- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView {
    return _indexList;
}

// 点击右侧索引列表的index后，tableview 滑动到哪一个section的index，返回index就好
- (NSInteger)tableView:(UITableView *)tableView
sectionForSectionIndexTitle:(NSString *)title
               atIndex:(NSInteger)index
{
    return index;
}
```

-以上-
