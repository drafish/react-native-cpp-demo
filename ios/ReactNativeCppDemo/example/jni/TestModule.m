#import "TestModule.h"
#import <DynamicLibraryDemo/Test.h>

@implementation TestExample

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(add:(int)numberA numberParameter:(int)numberB callback:(RCTResponseSenderBlock)callback)
{
  example::Test test;
  int c = test.add(numberA, numberB);
//  NSInteger c = numberA + numberB;
  callback(@[@(c)]);
}

@end
