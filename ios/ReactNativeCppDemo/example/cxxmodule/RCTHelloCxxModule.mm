#import "RCTHelloCxxModule.h"
#import "HelloCxxModule.h"

@implementation TestExample

RCT_EXPORT_MODULE()

- (std::unique_ptr<facebook::xplat::module::CxxModule>)createModule
{
  return std::make_unique<HelloCxxModule>();
}

@end
