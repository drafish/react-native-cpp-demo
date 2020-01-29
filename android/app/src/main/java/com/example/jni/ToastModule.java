// ToastModule.java

package com.example.jni;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import java.util.Map;
import java.util.HashMap;

public class ToastModule extends ReactContextBaseJavaModule {
  private static ReactApplicationContext reactContext;

  public ToastModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "ToastExample";
  }

  @ReactMethod
  public void show(String message, Callback callback) {
    message = "C/C++返回结果:" + stringFromJNI(message);
    callback.invoke(message);
  }

  public native String stringFromJNI(String message);

  static {
      System.loadLibrary("hello-jni");
  }
}