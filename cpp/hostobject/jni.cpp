#include <jni.h>
#include <jsi/jsi.h>
#include "TestBinding.h"

extern "C"
{
  JNIEXPORT void JNICALL
  Java_com_reactnativecppdemo_MainActivity_install(JNIEnv* env, jobject thiz, jlong runtimePtr)
  {
      auto test = std::make_unique<example::Test>();
      auto testBinding = std::make_shared<example::TestBinding>(std::move(test));
      jsi::Runtime* runtime = (jsi::Runtime*)runtimePtr;

      example::TestBinding::install(*runtime, testBinding);
  }
}
