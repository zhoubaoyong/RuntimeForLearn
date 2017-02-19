//
//  Person.m
//  Runtime和RunLoop
//
//  Created by  周保勇 on 17/2/16.
//  Copyright © 2017年  周保勇. All rights reserved.
//

#import "Person.h"
#import <objc/message.h>

@implementation Person
#pragma mark - 交换方法
+ (void)load{
    // 2.交换方法
    // class_getClassMethod(Class cls, SEL name) 获取类方法
    // class_getInstanceMethod(Class cls, SEL name) 获取实例方法
    // 获取eat的方法的地址
    Method eatMethod = class_getInstanceMethod(self, @selector(eat));
    // 获取run的方法的地址
    Method runMethod = class_getInstanceMethod(self, @selector(run));
    // 交换方法的地址：交换实现方式
    method_exchangeImplementations(runMethod, eatMethod);
    // 重新设置eat方法
//    method_setImplementation(eatMethod,imp_implementationWithBlock(^(id target,SEL action){
//        //自定义代码
//        NSLog(@"reset eat");
//    }));
}
+ (void)eat{
    NSLog(@"class:I am hungry！I want to eat!");
}
- (void)eat{
    NSLog(@"I am hungry！I want to eat!");
}
- (void)run{
    NSLog(@"run");
}
#pragma mark - 添加属性的实质
// 3.添加属性的实质
// 定义关联的key
static const char *key = "name";
- (void)setName:(NSString *)name{
    // 一般使用
//    _name = name;
    // runtime实质
    // 第一个参数：给哪个对象添加关联
    // 第二个参数：关联的key，通过这个key获取
    // 第三个参数：关联的value
    // 第四个参数:关联的策略
    objc_setAssociatedObject(self, key, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)name{
    // 一般使用
//    return _name;
    // runtime实质
    // 根据关联的key，获取关联的值。
    return objc_getAssociatedObject(self, key);
}
- (void)setDescriptionStr:(NSString *)descriptionStr{
    _descriptionStr = descriptionStr;
}
#pragma mark - 动态添加方法的实质
// 4.动态添加方法的实质
// void(*)()
// 默认方法都有两个隐式参数，
void play(id self,SEL sel)
{
    NSLog(@"%@ %@",self,NSStringFromSelector(sel));
}

// 当一个对象调用未实现的方法，会调用这个方法处理,并且会把对应的方法列表传过来.
// 刚好可以用来判断，未实现的方法是不是我们想要动态添加的方法
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    
    if (sel == @selector(play)) {
        // 动态添加play方法
        
        // 第一个参数：给哪个类添加方法
        // 第二个参数：添加方法的方法编号
        // 第三个参数：添加方法的函数实现（函数地址）
        // 第四个参数：函数的类型，(返回值+参数类型) v:void @:对象->self :表示SEL->_cmd
        class_addMethod(self, @selector(play), play, "v@:");
        
    }
    
    return [super resolveInstanceMethod:sel];
}
// 一般添加方法
//- (void)play{
//    // play node
//}
@end
