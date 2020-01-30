#include "HelloCxxModule.h"

HelloCxxModule::HelloCxxModule() {}

std::string HelloCxxModule::getName() {
  return "TestExample";
}

auto HelloCxxModule::getConstants() -> std::map<std::string, folly::dynamic> {
  return {
      {"one", 1}, {"two", 2}, {"animal", "fox"},
  };
}

auto HelloCxxModule::getMethods() -> std::vector<Method> {
  return {
      Method("foo", [](folly::dynamic args, Callback cb) { 
        example::Test test;
        int a = facebook::xplat::jsArgAsDouble(args, 0);
        int b = facebook::xplat::jsArgAsDouble(args, 1);
        int j = test.add(a, b);
        cb({j}); 
      }),
  };
}

extern "C" HelloCxxModule* createHelloCxxModule() {
  return new HelloCxxModule();
}
