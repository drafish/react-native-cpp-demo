APP_BUILD_SCRIPT := Android.mk

APP_ABI := armeabi-v7a x86 arm64-v8a x86_64
APP_PLATFORM := android-16

APP_STL := c++_shared

APP_CFLAGS := -Wall -Werror -fexceptions -frtti
APP_CPPFLAGS := -std=c++1y
# Make sure every shared lib includes a .note.gnu.build-id header
APP_LDFLAGS := -Wl,--build-id
