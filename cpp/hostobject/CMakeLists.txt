# For more information about using CMake with Android Studio, read the
# documentation: https://d.android.com/studio/projects/add-native-code.html

# Sets the minimum version of CMake required to build the native library.

cmake_minimum_required(VERSION 3.4.1)

# Creates and names a library, sets it as either STATIC
# or SHARED, and provides the relative paths to its source code.
# You can define multiple libraries, and CMake builds them for you.
# Gradle automatically packages shared libraries with your APK.

# Needed to locate double-conversion src correctly for folly includes

include_directories(
    ../../node_modules/react-native/React
    ../../node_modules/react-native/React/Base
    ../../node_modules/react-native/ReactCommon/jsi
    ../../ios/Pods/Folly
    ../../ios/Pods/DoubleConversion
    ../../ios/Pods/boost-for-react-native
    ../../ios/Pods/glog/src
)

add_definitions(
    -DFOLLY_USE_LIBCPP=1
    -DFOLLY_NO_CONFIG=1
    -DFOLLY_HAVE_MEMRCHR=1
)

add_library( # Sets the name of the library.
        cpp_module_jni

        # Sets the library as a shared library.
        SHARED

        # Provides a relative path to your source file(s).
        ../../node_modules/react-native/ReactCommon/jsi/jsi/jsi.cpp
        ../src/Test.cpp
        TestBinding.cpp
        jni.cpp)

target_link_libraries(cpp_module_jni
                      android
                      log)
