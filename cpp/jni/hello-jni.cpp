#include <jni.h>

extern "C" {
    JNIEXPORT jstring JNICALL
    Java_com_example_jni_TestModule_stringFromJNI( JNIEnv* env, jobject thiz, jstring jstr )
    {
        return jstr;
    }
}
