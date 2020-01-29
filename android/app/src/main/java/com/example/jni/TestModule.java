package com.example.jni;

import com.facebook.react.bridge.NativeModule;
import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

import java.util.Map;
import java.util.HashMap;

public class TestModule extends ReactContextBaseJavaModule {
  private static ReactApplicationContext reactContext;

  public TestModule(ReactApplicationContext reactContext) {
    super(reactContext);
    this.reactContext = reactContext;
  }

  @Override
  public String getName() {
    return "TestExample";
  }

  @ReactMethod
  public void stringFunc(String message, Callback callback) {
    callback.invoke(stringFromJNI(message));
  }

  @ReactMethod
  public void intFunc(int a, int b, Callback callback) {
    callback.invoke(intFromJNI(a, b));
  }

  public native String stringFromJNI(String message);

  public native int intFromJNI(int a, int b);

  static {
      System.loadLibrary("hello-jni");
  }
}