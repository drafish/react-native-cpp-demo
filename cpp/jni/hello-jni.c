#include <jni.h>

JNIEXPORT jstring JNICALL
Java_com_example_jni_ToastModule_stringFromJNI( JNIEnv* env, jobject thiz, jstring jstr )
{
    return jstr;
}