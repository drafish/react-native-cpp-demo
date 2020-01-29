#include <jni.h>
#include "../src/Test.h"

extern "C" {
    JNIEXPORT jstring JNICALL
    Java_com_example_jni_TestModule_stringFromJNI( JNIEnv* env, jobject thiz, jstring jstr )
    {
        return jstr;
    }

    JNIEXPORT jint JNICALL
    Java_com_example_jni_TestModule_intFromJNI( JNIEnv* env, jobject thiz, jint a, jint b )
    {
        example::Test test;
        return test.add(a, b);
    }
}
