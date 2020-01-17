#import <React/RCTCxxModule.h>

NS_ASSUME_NONNULL_BEGIN

@interface RCTHelloCxxModule : RCTCxxModule

- (std::unique_ptr<facebook::xplat::module::CxxModule>)createModule;

@end

NS_ASSUME_NONNULL_END
