#import "CheckingAPIAvailability.h"

@implementation NewInIOS26
- (NSString *)describe { return @"new"; }
@end

NSString *notOnMac(void) { return @"called"; }

NSString *staleAPI(void) { return @"stale"; }

NSString *freshAPI(void) { return @"fresh"; }
