## 前言
React Native是一个非常优秀的框架，它使得Web前端开发工程师也具备了移动端原生应用的开发能力。而且它还可以集成原生模块供JavaScript调用，弥补JavaScript在高性能和多线程上的短板。

然而，RN官方文档只介绍了怎么集成Java和Object-C，并没有介绍怎么集成C++。仅是在IOS使用指南中提到了可以集成C++，在Android使用指南中更是只字未提。我写这个demo主要是为了补充RN官方文档中对C++集成部分的缺失。

我参考了社区的几个demo和博客，还有Android的官方文档，总结出三种集成C++的方案。相关引用我会在下面讲解过程中逐步给出。commit记录和我下面的讲解过程基本相符，方便大家结合代码来看，比较每一步之间的差异。

## Android
大家可以看到我demo中前两个commit分别是，初始化RN项目，集成Android端原生模块。这两步没什么难度，我完全是参考[RN官方文档](https://facebook.github.io/react-native/docs/native-modules-android)来写的。大家看下文档都可以轻松实现，我也就不赘述了。完成了这两步，我们便有了一个集成原生模块的demo，可以在js层调用java层的代码。接下来我们想办法在这个Java原生模块中集成C++的代码。

### JNI
JNI是为了方便Java调用C、C++等本地代码所封装的一层接口。Android官方已经提供了利用JNI集成C的[文档](https://developer.android.com/ndk/samples/sample_hellojni?hl=zh-cn)和[demo](https://github.com/android/ndk-samples/tree/master/hello-jni)。大家可以看到我的[commit记录](https://github.com/drafish/react-native-cpp-demo/commit/4c19f00762aab2368bed4daa863d8aa8d8943c50)，基本上是完全复制了这个demo。我简单讲解下这个commit。

首先是`hello-jni.c`文件
```c
JNIEXPORT jstring JNICALL
Java_com_example_jni_ToastModule_stringFromJNI( JNIEnv* env, jobject thiz )
```
`Java_com_example_jni_ToastModule_stringFromJNI`方法对应的是`android/app/src/main/java/com/example/jni/ToastModule.java`的`stringFromJNI`方法。
```java
public native String stringFromJNI();
```
在Java中声明了方法，具体实现写在C中，Java层对该方法的调用都会打到C层对应的方法上。

然后是`CMakeLists.txt`文件
```
add_library(hello-jni SHARED
            hello-jni.c)

```
这里声明了编译生成的库名和编译需要的源文件。Java中需要加载的库名就是在这里声明的。
```java
System.loadLibrary("hello-jni");
```

我们需要在`android/app/build.gradle`中配置项
`externalNativeBuild`中将`CMakeLists.txt`文件配置进去。
```
externalNativeBuild {
    cmake {
        version '3.10.2'
        path "../../cpp/jni/CMakeLists.txt"
    }
}
```

到这里，我们已经成功将C集成进Java。接下来我们只需要在原来暴露给js调用的java方法中调用`stringFromJNI`方法，这样就实现了`js->java->c`的调用流程。
```java
public void show(String message, int duration) {
  message = message + " | " + stringFromJNI();
  Toast.makeText(getReactApplicationContext(),message, duration).show();	    
}
```

我在接下来的几个commit中做了点优化，更加方便demo的展示与阅读。大家可以看到，JNI方案本身与RN并没有什么关系，只是单纯的在Java原生模块中集成C/C++，JS对C/C++的调用还是需要通过Java。而且每导出一个C/C++方法，都需要包装一层JNI，非常繁琐。

### CxxModule
事实上，RN已经对这种情况作出了优化。RN的CxxModule可以让我们直接使用C++编写原生模块。但奇怪的是，RN官方文档中对CxxModule只字未提，仅是在源码中写了一个SampleCxxModule。如果不是Kudo大神写了篇文章[如何编写 React Native 的 CxxModule](https://maxiee.github.io/post/ReactNativeCxxModulemd/)，我都不知道居然还有这样的操作。

Kudo在文章中对这部分内容已经介绍的比较详细了，我就不再赘述了。这里对CxxModule和JNI两种方案做个对比。

大家应该发现这两种方案中JS层对Native Module的调用并没有什么差别，差别主要在Bridge层。对RN通信机制不太了解的同学建议看下这篇文章[ReactNative源码篇：通信机制](https://github.com/sucese/react-native/blob/master/doc/ReactNative%E6%BA%90%E7%A0%81%E7%AF%87/6ReactNative%E6%BA%90%E7%A0%81%E7%AF%87%EF%BC%9A%E9%80%9A%E4%BF%A1%E6%9C%BA%E5%88%B6.md)。js调java的流程是这样`js->bridge->java`。利用JNI集成c++以后，调用流程是这样`js->bridge->java->c++`。虽然CxxModule还是需要在java层将Module注册进Bridge，但是注册完了以后，后续的调用流程就不需要java参与了，所以调用流程就变成了这样`js->bridge->c++`。

另外，我再补充几点。

- 编译CxxModule需要用到的三个库`libfolly libfb libreactnative`，必须要通过编译RN源码才能得到。
- 编译CxxModule需要用到的四个第三方库`folly boost glog double-conversion`，是在编译RN源码的过程中下载下来的。
- Android端集成C++有三种编译方案，这个demo中选择的是[ndk-build](https://developer.android.com/ndk/guides/ndk-build.html?hl=zh-cn)，所以编译配置文件是`Android.mk`和`Application.mk`
- 不建议在windows下跑这个demo，虽然我后来还是跑通了，但是坑很深。我的开发环境是MacOS。Linux下没试过，但应该问题不大

### HostObject
不管是JNI还是CxxModule，这两种方案都离不开Bridge，这导致JS调C++始终是异步的。而在RN的新架构中提供了一种JSI机制，可以为C++创建一个HostObject对象，直接挂载到js的上下文中，使得js可以获取到C++对象的引用。然后，js调c++的流程就变成了这样js->c++。就这样简单直接，而且还是同步的。

对JSI不了解的同学，建议看下Maxiee同学的[React Native 笔记](https://reactnative.maxieewong.com/docs/advanced/jsi/)。目前JSI机制在RN的源码中已经大量使用，但官方还没有相应的文档和demo，应该是还没有准备好对外开放这个特性。不过，社区已经有大神研究出怎么使用JSI来集成C++。大家可以看下这篇文章[React Native JSI 尝鲜](https://maxiee.github.io/post/ReactNativeJSIChallengemd/)，对应的demo是这个[react-native-hostobject-demo](https://github.com/ericlewis/react-native-hostobject-demo)。这个demo中只在IOS端做了集成，Android端没有。不过已经有人提了个[Add Android support](https://github.com/ericlewis/react-native-hostobject-demo/pull/4)的PR。

大家可以看到我的commit记录[添加hostobject示例代码](https://github.com/drafish/react-native-cpp-demo/commit/54d83aa44ae978d2327edbe7e9882a3ca6485fc9)，基本上就是复制了`react-native-hostobject-demo`中的代码。我这里主要讲下commit记录[android端集成hostobject](https://github.com/drafish/react-native-cpp-demo/commit/f70e5b01f4a0989e3c52052cabe56522b2d5d450)。大家可以看到，`android/app/src/main/java/com/reactnativecppdemo/MainActivity.java`也用到了JNI。
```java
@Override
public void onReactContextInitialized(ReactContext context) {
  install(context.getJavaScriptContextHolder().get());
}

public native void install(long jsContextNativePointer);
```
在ReactContext初始化的时候调用`install`方法，将js上下文引用传给c++。然后在c++中将HostObject挂载到js上下文上。

这里需要特别提一下的是，编译同样需要用到`folly boost glog double-conversion`这四个第三方库。这四个库有两种方式可以获取到，一是通过在编译RN源码的过程中下载获得，因为这几个库是编译RN源码的依赖包；二是在ios下执行`pod install`命令，IOS编译所需相关的依赖包括这几个库。在`CMakeLists.txt`中我是从`ios/Pods`目录下引用的，把这四个依赖包的引用路径换成`node_modules/react-native/ReactAndroid/build/third-party-ndk`也是可以的。不过这个前提是，需要先编译过RN源码，然后这些依赖包才会下载下来。
```
include_directories(
    ../../node_modules/react-native/React
    ../../node_modules/react-native/React/Base
    ../../node_modules/react-native/ReactCommon/jsi
    ../../ios/Pods/Folly
    ../../ios/Pods/DoubleConversion
    ../../ios/Pods/boost-for-react-native
    ../../ios/Pods/glog/src
)
```

## IOS
IOS端集成C++比Android端要容易。因为Object-C是C语言的超集，与C++有着良好的兼容性。只要做好编译相关配置，Object-C中可以直接引用C++代码。不过大概正是因为容易，社区大神们反而觉得没有写教程的必要。应该做哪些配置，怎么做这些配置，这方面的资料很少。我这里就简单讲下怎么配置，给不熟悉IOS和XCode的同学提供一个参考。

### JNI
这里特别声明一下，这个JNI标题，还有`ios/ReactNativeCppDemo/example/jni`目录，其实都和JNI没有半毛钱关系，纯粹是为了和Android保持队形。

大家可以看到我的commit记录，我先参考[RN官方文档](https://facebook.github.io/react-native/docs/native-modules-ios)实现了一个Native Module，然后在这个Native Module上集成了C++。

先来看这个commit[ios端原生模块demo](https://github.com/drafish/react-native-cpp-demo/commit/d43ed2ce1d05abc0251376a7ef3d92b72776f25b)，我参考[RN官方文档](https://facebook.github.io/react-native/docs/native-modules-ios)实现了一个Native Module。这一步没什么难度，相信大家看下文档都可以实现。但其中有一个文件`ios/ReactNativeCppDemo.xcodeproj/project.pbxproj`，不熟悉XCode的同学可能会看着有点懵逼。这是XCode的项目配置文件，这个文件包含了XCode项目的所有文件路径和配置。

大家可以看到我在这个文件中将`TestModule.h TestModule.m`两个文件引入到`ios/ReactNativeCppDemo`目录下。如果没有这一步，即使你在`ios/ReactNativeCppDemo`目录下创建了这两个文件，XCode也不会认为这两个文件是这个项目的文件。

具体操作方法并不是直接修改`project.pbxproj`文件，而是在XCode中选中你要导入的目标文件夹，然后右键选择`Add Files to "some path"`，然后选择你要的文件或者文件夹。

再来看commit[ios端集成c++](https://github.com/drafish/react-native-cpp-demo/commit/da2a60a36589034e46a36d062471d46a90b48e6e)，我把`Test.cpp Test.h`，两个文件引入项目，然后在`TestModule.m`中`import "Test.h"`。

这里需要提两点

一是需要将`TestModule.m`的文件类型改成`Object-C++ Source`。具体操作方法是，打开这个文件，然后看右边的侧边栏，有个`Type`选项，默认是`Default - Object-C Source`，改下就好了

二是将项目的`C++ Language Dialect`配置改成`C++14[-std=c++14]`。具体操作方法是，选中左边侧边栏的顶层目录（不是Pods目录），然后选择`Build Settings`，找到`C++ Language Dialect`选项，默认是`GNU++11[-std=gnu++11]`，改下就好了。

### CxxModule
再来看commit[ios端集成CxxModule](https://github.com/drafish/react-native-cpp-demo/commit/076337316260c6ea4dd0b94bbf53bc443787a54c)，我移除了JNI方案中添加的`TestModule.h TestModule.m`，将`RCTHelloCxxModule.h RCTHelloCxxModule.mm HelloCxxModule.cpp HelloCxxModule.h`添加进项目。然后又改了`Build Settings`中的`Header Search Paths`和`Other C++ Flags`。具体操作方法我就不写了，参考前面的做法就可以了。

这里需要提一点，就是CxxModule名的问题，大家应该注意到`HelloCxxModule.cpp`中有一个方法
```
std::string HelloCxxModule::getName() {
  return "TestExample";
}
```
这里会返回这个Module的方法名，但这个方法只对Android端有效，IOS中Module名定义在`RCTHelloCxxModule.h`中
```
@interface TestExample : RCTCxxModule
```
`RCTHelloCxxModule.mm`中的Module名需要和`RCTHelloCxxModule.h`中的一样
```
@implementation TestExample
```

### HostObject
再来看commit[ios端集成hostobject](https://github.com/drafish/react-native-cpp-demo/commit/12371046a04fa26da34ece361e75e37ead148cdc)，我移除了CxxModule方案中添加的`RCTHelloCxxModule.h RCTHelloCxxModule.mm HelloCxxModule.cpp HelloCxxModule.h`，将`TestBinding.cpp TestBinding.h`添加进项目，将`AppDelegate.m`的文件类型改成`Object-C++ Source`，`Build Settings`没有改动，和CxxModule完全一样.

这里需要提一点，就是在`App.js`中，我没有`import TestExample from "./TestExample";`，而是直接`console.warn(global.nativeTest.runTest(1, 2));`。不知道为什么，如果我从`TestExample.js`中import，就会一直报错。直接`global.nativeTest`这样调用，有时候报错，有时候不报错。我试过Reload，大概有超过1/2的概率会出现报错。Reload的问题在[React Native JSI 尝鲜](https://maxiee.github.io/post/ReactNativeJSIChallengemd/)中有提到过，但在Android端没碰到这个问题。另外，文章中还提到，在Debug模式跑不起来，我这边碰到了，两端都有这个问题。

## 总结
到这里，两个端，三种方案就都讲完了。我们来总结一下。

- JNI
    - 优点：集成方式简单，不需要依赖第三方库
    - 缺点：Android端需要写JNI封装比较麻烦，调用流程较长，影响性能

- CxxModule
    - 优点：Android端不需要写JNI封装，调用流程不需要JVM参与，性能较好
    - 缺点：Android端需要从RN源码编译，首次编译时间太长

- HostObject
    - 优点：调用流程最直接，而且是同步操作，性能最好
    - 缺点：方案不太成熟，无法开启Debug模式，IOS端Reload报错

综合考虑三种方案的优缺点，我比较推荐CxxModule方案，因为只是首次编译时间比较长，二次编译就很快了。如果有精通RN的大神能搞定HostObject方案中的问题，我觉得还是可以考虑的，毕竟这个方案的性能是最好的。但我目前水平还很菜，不敢用HostObject，还是得多啃啃源码。
