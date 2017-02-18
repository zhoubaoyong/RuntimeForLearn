一、什么是Runtime？
RunTime简称运行时。OC就是运行时机制，也就是在运行时候的一些机制，其中最主要的是消息机制。
对于C语言，函数的调用在编译的时候会决定调用哪个函数。
对于OC的函数，属于动态调用过程，在编译的时候并不能决定真正调用哪个函数，只有在真正运行的时候才会根据函数的名称找到对应的函数来调用。
事实证明：
在编译阶段，OC可以调用任何函数，即使这个函数并未实现，只要声明过就不会报错。
在编译阶段，C语言调用未实现的函数就会报错。
二、Runtime开源获取
Runtime底层是开源的，任何时候你都能从 http://opensource.apple.com. 获取。事实上查看 Objective-C 源码是我理解它是如何工作的第一种方式，在这个问题上要比读苹果的文档要好。你可以下载适合 Mac OS X 10.6.2 的 objc4-437.1.tar.gz。（译注：最新objc4-551.1.tar.gz：链接http://opensource.apple.com/tarballs/objc4/objc4-551.1.tar.gz）三
For more details see [GitHub Flavored Markdown](https://guides.github.com/features/mastering-markdown/).
