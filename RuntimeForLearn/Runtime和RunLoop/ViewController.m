//
//  ViewController.m
//  Runtime和RunLoop
//
//  Created by  周保勇 on 17/2/15.
//  Copyright © 2017年  周保勇. All rights reserved.
//  超链地址：http://www.jianshu.com/p/e071206103a4
/* 一、runtime简介
 
 RunTime简称运行时。OC就是运行时机制，也就是在运行时候的一些机制，其中最主要的是消息机制。
 对于C语言，函数的调用在编译的时候会决定调用哪个函数。
 对于OC的函数，属于动态调用过程，在编译的时候并不能决定真正调用哪个函数，只有在真正运行的时候才会根据函数的名称找到对应的函数来调用。
 事实证明：
 在编译阶段，OC可以调用任何函数，即使这个函数并未实现，只要声明过就不会报错。
 在编译阶段，C语言调用未实现的函数就会报错。 */
/* 二、runtime应用场景
 1.类和对象的掉用本质都是发送消息
 2.交换方法：一般用于给系统方法添加更多操作，比如添加打印log等；例子：第一种方案见Person类中eat和run方法交换和第二种方案见UIImage的分类
 3.添加属性的实质：见Person类中name属性的添加
 4.动态添加方法的实质：见Person类中添加play的实质
 5.获取类的信息：方法列表，属性列表
 */
//当类调用方法->底层是通过objc_msgSend(target,SEL sel)给类发送消息(target为该类，sel为方法的编号)->在该类方法映射表中Method list中查找该方法实现的IMP指针->IMP指针指向方法的实现代码并调用代码
// 以上属Person为例：[p eat] -> objc_msgSend(p, @selector(eat))给类发消息 -> 在Person类中的Method list查找eat方法的IMP指针 -> eat方法的IMP指针指向方法的实现并调用代码
// 这只是简单的描述，Runtime的底层详情和方法调用步骤见超链：http://www.cocoachina.com/ios/20141008/9844.html和http://www.cnblogs.com/qmmq/p/5215910.html
#import "ViewController.h"
#import <objc/message.h>
#import "Person.h"
#import "UIImage+Extension.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //1.类和对象的掉用本质都是发送消息
    // 创建person对象
    Person *p = [[Person alloc] init];
    
    // 调用对象方法
    [p eat];
    
    // 本质：让对象发送消息
//    objc_msgSend(p, @selector(eat));
    
    // 调用类方法的方式：两种
    // 第一种通过类名调用
    [Person eat];
    // 第二种通过类对象调用
    [[Person class] eat];
    
    // 用类名调用类方法，底层会自动把类名转换成类对象调用
    // 本质：让类对象发送消息
//    objc_msgSend([Person class], @selector(eat));
    
    // 3.动态添加方法
    [p performSelector:@selector(play)];
    // 替换方法的两种方案
    UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectMake(50, 100, 100, 100)];
    imageView.image = [UIImage imageNamed:@"0003"];
    [self.view addSubview:imageView];
    // 获取类的信息
    // 获取属性信息
    u_int               pCount;
    objc_property_t*    properties= class_copyPropertyList([Person class], &pCount);
    for (int i = 0; i < pCount ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        NSString *strName = [NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        NSLog(@"%@",strName);
    }
    // 获取方法信息
    u_int               mCount;
    Method*    methods= class_copyMethodList([Person class], &mCount);
    for (int i = 0; i < mCount ; i++)
    {
        SEL name = method_getName(methods[i]);
        NSString *strName = [NSString  stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        NSLog(@"%@",strName);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
