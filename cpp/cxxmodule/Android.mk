LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

RN_DIR := $(LOCAL_PATH)/../../node_modules/react-native
RN_BUILD_THIRD_PARTY_DIR := $(RN_DIR)/ReactAndroid/build/third-party-ndk
RN_BUILD_LIB_DIR := $(RN_DIR)/ReactAndroid/build/react-ndk/exported/

LOCAL_MODULE := rnpackage-hellocxx

LOCAL_SRC_FILES := \
  HelloCxxModule.cpp \
  ../src/Test.cpp \

LOCAL_C_INCLUDES := $(RN_DIR)/ReactCommon
LOCAL_C_INCLUDES += $(RN_DIR)/ReactAndroid/src/main/jni/react/jni
LOCAL_C_INCLUDES += $(RN_DIR)/ReactAndroid/src/main/jni/first-party/fb/include
LOCAL_C_INCLUDES += $(RN_BUILD_THIRD_PARTY_DIR)/boost/boost_1_63_0
LOCAL_C_INCLUDES += $(RN_BUILD_THIRD_PARTY_DIR)/folly
LOCAL_C_INCLUDES += $(RN_BUILD_THIRD_PARTY_DIR)/glog/exported
LOCAL_C_INCLUDES += $(RN_BUILD_THIRD_PARTY_DIR)/double-conversion

LOCAL_EXPORT_C_INCLUDES := $(LOCAL_C_INCLUDES)

LOCAL_SHARED_LIBRARIES := libfolly libfb libreactnative

include $(BUILD_SHARED_LIBRARY)

BASE_DIR := $(LOCAL_PATH)
include $(BASE_DIR)/SoWrapper.mk
