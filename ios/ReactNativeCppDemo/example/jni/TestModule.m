#import "TestModule.h"

@implementation TestExample

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(add:(NSInteger)numberA numberParameter:(NSInteger)numberB callback:(RCTResponseSenderBlock)callback)
{
  NSInteger c = numberA + numberB;
  callback(@[@(c)]);
}

@end
