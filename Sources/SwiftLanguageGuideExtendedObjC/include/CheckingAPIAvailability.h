@import Foundation;

// Declarations for the "Checking API Availability" experiments, marked with
// the Objective-C availability macros so the test targets can see how each
// one behaves from Objective-C and how it imports into Swift.

NS_ASSUME_NONNULL_BEGIN

API_AVAILABLE(ios(26.0))
@interface NewInIOS26 : NSObject
- (NSString *)describe;
@end

API_UNAVAILABLE(macos)
NSString *notOnMac(void);

API_DEPRECATED("Use freshAPI instead.", ios(13.0, 16.0))
NSString *staleAPI(void);

NSString *freshAPI(void);

NS_ASSUME_NONNULL_END
