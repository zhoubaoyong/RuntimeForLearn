//
//  Person.h
//  Runtime和RunLoop
//
//  Created by  周保勇 on 17/2/16.
//  Copyright © 2017年  周保勇. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Person : NSObject
/**
 *  添加属性：
    下句代码：生成了属性的getter和setter方法和一个带下划线的属性变量
    如果重写了getter和setter方法下句代码必须生命一个属性的带下划线的变量，因为重写属性的这两个方法，就不会自动生成带下划线的属性变量
 */
@property (copy, nonatomic) NSString * name;
@property (copy, nonatomic) NSString * descriptionStr;
+ (void)eat;
- (void)eat;
- (void)run;
- (void)play;
@end
