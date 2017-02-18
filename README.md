<h1>一、什么是Runtime？</h1>
</br>
    RunTime简称运行时。OC就是运行时机制，也就是在运行时候的一些机制，其中最主要的是消息机制。
    对于C语言，函数的调用在编译的时候会决定调用哪个函数。
    对于OC的函数，属于动态调用过程，在编译的时候并不能决定真正调用哪个函数，只有在真正运行的时候才会根据函数的名称找到对应的函数来调用。
    事实证明：
    在编译阶段，OC可以调用任何函数，即使这个函数并未实现，只要声明过就不会报错。
    在编译阶段，C语言调用未实现的函数就会报错。
<br>
<h1>二、Runtime开源获取</h1>
<br>
    Runtime底层是开源的，任何时候你都能从 http://opensource.apple.com. 获取。事实上查看 Objective-C 源码是我理解它是如何工作的第一种方式，在这个问题上要比读苹果的文档要好。你可以下载适合 Mac OS X 10.6.2 的 objc4-437.1.tar.gz。（译注：最新objc4-551.1.tar.gz：链接http://opensource.apple.com/tarballs/objc4/objc4-551.1.tar.gz）
<br>
<h1>三、Runtime使用场景</h1>
<br>
<h2>1.类和对象的掉用本质都是发送消息</h2>
    // 创建person对象
    Person *p = [[Person alloc] init];
    // 调用对象方法
    [p eat];
    
    // 本质：让对象发送消息
    objc_msgSend(p, @selector(eat));
    
    // 调用类方法的方式：两种
    // 第一种通过类名调用
    [Person eat];
    // 第二种通过类对象调用
    [[Person class] eat];
    
    // 用类名调用类方法，底层会自动把类名转换成类对象调用
    // 本质：让类对象发送消息
    objc_msgSend([Person class], @selector(eat));
<h2>2.交换方法的实现：</h2>
一般用于给系统方法添加更多操作，比如添加打印log等；<br>
例子：用自定义的方法imageWithNamed:替换UIImage的系统方法imageName:
<h3>第一种方案</h3>
<p>
/**
 *  load方法是在程序代码加载进内存是调用一次
 */
+ (void)load{
    // 交换方法
    // 第一种方案
    // 获取imageWithName方法地址
    Method imageWithName = class_getClassMethod(self, @selector(imageWithName:));
    
    // 获取imageWithName方法地址
    Method imageName = class_getClassMethod(self, @selector(imageNamed:));
    
    // 交换方法地址，相当于交换实现方式
    method_exchangeImplementations(imageWithName, imageName);
    }
<p>
<h3>第二种方案</h3>

+ (void)load{
    //获取系统方法
    Method imageName = class_getClassMethod(self, @selector(imageNamed:));
    Method imageWithName = class_getClassMethod(self, @selector(imageWithName:));
    
    /* IMP 它是一个指向方法实现的指针，每一个方法都一个对应的IMP指针。我们可以直接调用方法的IMP指针，来避免方法调用死循环的问题
    实际上直接调用一个方法的IMP指针的效率是高于调用方法本身的，如果有一个合适的时机获取到方法的IMP的话，可以试着调用IMP而不用调用方法。*/
    //获取方法实现的指针
    IMP imageName_IMP = method_getImplementation(imageName);
    IMP imageWithName_IMP = method_getImplementation(imageWithName);
    //重新设置方法实现
    method_setImplementation(imageName, imageWithName_IMP);
    method_setImplementation(imageWithName, imageName_IMP);
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
<h2>3.添加属性：</h2>
<p>添加属性</p>
@interface Person : NSObject
/**
 *  添加属性：
    下句代码：生成了属性的getter和setter方法和一个带下划线的属性变量
    如果重写了getter和setter方法下句代码必须生命一个属性的带下划线的变量，因为重写属性的这两个方法，就不会自动生成带下划线的属性变量
 */
@property (copy, nonatomic) NSString * name;
@end
@implementation Person
- (void)setName:(NSString *)name{   
    _name = name;
}
- (NSString *)name{
    return _name;
}
@end
<p>添加属性的实质</p>

// 定义关联的key
static const char *key = "name";
- (void)setName:(NSString *)name{
    // runtime实质
    // 第一个参数：给哪个对象添加关联
    // 第二个参数：关联的key，通过这个key获取
    // 第三个参数：关联的value
    // 第四个参数:关联的策略
    objc_setAssociatedObject(self, key, name, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (NSString *)name{
    // runtime实质
    // 根据关联的key，获取关联的值。
    return objc_getAssociatedObject(self, key);
}
<h2>4.动态添加方法的实质：见Person类中添加play的实质</h2>
<p>一般添加方法</p>

- (void)play{
    // play node
}
<p>动态添加方法的实质</p>

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
<h2>5.获取类的信息：</h2>
<p>方法列表</p>

     u_int               mCount;<br>
    Method*    methods= class_copyMethodList([Person class], &mCount);
    for (int i = 0; i < mCount ; i++)
    {
        SEL name = method_getName(methods[i]);
        NSString *strName = [NSString  stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        NSLog(@"%@",strName);
    }
<p>属性列表</p>

    u_int               pCount;<br>
    objc_property_t*    properties= class_copyPropertyList([Person class], &pCount);
    for (int i = 0; i < pCount ; i++)
    {
        const char* propertyName = property_getName(properties[i]);
        NSString *strName = [NSString  stringWithCString:propertyName encoding:NSUTF8StringEncoding];
        NSLog(@"%@",strName);
    }
     u_int               mCount;
    Method*    methods= class_copyMethodList([Person class], &mCount);
    for (int i = 0; i < mCount ; i++)
    {
        SEL name = method_getName(methods[i]);
        NSString *strName = [NSString  stringWithCString:sel_getName(name) encoding:NSUTF8StringEncoding];
        NSLog(@"%@",strName);
    }
