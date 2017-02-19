//
//  UIImage+Extension.m
//  Runtime和RunLoop
//
//  Created by  周保勇 on 17/2/18.
//  Copyright © 2017年  周保勇. All rights reserved.
//  应用场景分析：程序中有许多个imageName:,我想在对项目改动最小的情况下，在当每个UIImage执行完imageName:以后就在控制台把自己的名字打印出来，方便去做调试或者了解项目结构
/* Category
 在Catagory中重写一个方法，就会覆盖它的原有方法实现，但是，这样做以后就没有办法调用系统原有的方法，因为在一个方法里调用自己的方法会是一个死循环。所以我们的解决办法就是，另外写一个方法来和imageWithName:“交换”，这样外部调用imageName:就会调到新建的这个方法中，同样，我们调用新建的方法就会调用到系统的imageName:
 */
/* IMP 它是一个指向方法实现的指针，每一个方法都一个对应的IMP指针。我们可以直接调用方法的IMP指针，来避免方法调用死循环的问题
 实际上直接调用一个方法的IMP指针的效率是高于调用方法本身的，如果有一个合适的时机获取到方法的IMP的话，可以试着调用IMP而不用调用方法。*/
#import "UIImage+Extension.h"
#import <objc/runtime.h>


@implementation UIImage (Extension)
/**
 *  load方法是在程序代码加载进内存是调用一次
 */
+ (void)load{
    // 交换方法
    // 第一种方案
//    // 获取imageWithName方法地址
//    Method imageWithName = class_getClassMethod(self, @selector(imageWithName:));
//    
//    // 获取imageWithName方法地址
//    Method imageName = class_getClassMethod(self, @selector(imageNamed:));
//    
//    // 交换方法地址，相当于交换实现方式
//    method_exchangeImplementations(imageWithName, imageName);
    
    // 第二种方案
    //获取系统方法
    Method imageName = class_getClassMethod(self, @selector(imageNamed:));
    Method imageWithName = class_getClassMethod(self, @selector(imageWithName:));
    
    //获取方法实现的指针
    IMP imageName_IMP = method_getImplementation(imageName);
    IMP imageWithName_IMP = method_getImplementation(imageWithName);
    //重新设置方法实现
    method_setImplementation(imageName, imageWithName_IMP);
    method_setImplementation(imageWithName, imageName_IMP);
//    class_replaceMethod(self, @selector(imageNamed:), imageWithName_IMP, NULL);
//    class_replaceMethod(self, @selector(imageWithName:), imageName_IMP, NULL);
}
/**
 *  自定义替换方法：既能加载图片又能打印
 */
+ (instancetype)imageWithName:(NSString *)name
{
    // 这里调用imageWithName，相当于调用imageName
    UIImage *image = [self imageWithName:name];
    
    if (image == nil) {
        NSLog(@"加载空的图片");
    }
    NSLog(@"加载图片");
    return image;
}
@end
