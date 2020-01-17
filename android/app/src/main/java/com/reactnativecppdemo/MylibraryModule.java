package com.reactnativecppdemo;

import com.facebook.react.bridge.ReactApplicationContext;
import com.facebook.react.bridge.ReactContextBaseJavaModule;
import com.facebook.react.bridge.ReactMethod;
import com.facebook.react.bridge.Callback;

public class MylibraryModule extends ReactContextBaseJavaModule {

    static {
        System.loadLibrary("cpp_module_jni"); // this loads the library when the class is loaded
    }

    private final ReactApplicationContext reactContext;

    public MylibraryModule(ReactApplicationContext reactContext) {
        super(reactContext);
        this.reactContext = reactContext;
    }

    @Override
    public String getName() {
        return "Mylibrary";
    }

    @ReactMethod
    public void sampleMethod(String stringArgument, int numberArgument, Callback callback) {
        // TODO: Implement some actually useful functionality
        int j = runTest();
        callback.invoke("Received numberArgument: " + numberArgument + " stringArgument: " + stringArgument + " c++Result: " + j);
    }

    public native int runTest();
}
