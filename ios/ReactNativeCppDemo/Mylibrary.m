#import "Mylibrary.h"
#import "Test.h"

@implementation Mylibrary

RCT_EXPORT_MODULE()

RCT_EXPORT_METHOD(sampleMethod:(NSString *)stringArgument numberParameter:(nonnull NSNumber *)numberArgument callback:(RCTResponseSenderBlock)callback)
{
  example::Test test;
  int j = test.runTest();
    // TODO: Implement some actually useful functionality
  callback(@[[NSString stringWithFormat: @"numberArgument: %@ stringArgument: %@ c++Result: %d", numberArgument, stringArgument, j]]);
}

@end
