@import XCTest;
@import SwiftLanguageGuideExtendedObjC;

// Experiments for the Objective-C section of "Checking API Availability". Run
// them on an iOS simulator with scripts/test-ios.sh. The declarations they
// use are in Sources/SwiftLanguageGuideExtendedObjC.

@interface CheckingAPIAvailabilityTests : XCTestCase
@end

@implementation CheckingAPIAvailabilityTests

- (BOOL)runningOniOS26OrNewer {
    return NSProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26;
}

- (void)testAvailableAgreesWithProcessInfo {
    // Arrange
    BOOL taken = NO;

    // Act
    if (@available(iOS 26.0, *)) { taken = YES; }

    // Assert
    XCTAssertEqual(taken, self.runningOniOS26OrNewer);
}

- (void)testNegatedAvailableIsTheComplement {
    // Arrange
    BOOL taken = NO;

    // Act
    if (!@available(iOS 26.0, *)) { taken = YES; }

    // Assert
    XCTAssertEqual(taken, !self.runningOniOS26OrNewer);
}

- (void)testWildcardCoversPlatformsNotNamed {
    // Arrange
    BOOL taken = NO;

    // Act
    if (@available(macOS 26.0, *)) { taken = YES; }

    // Assert
    XCTAssertTrue(taken);
}

- (void)testCheckedUseRaisesTheFloorInsideTheBlock {
    // Arrange
    NSString *result = @"plain";

    // Act
    if (@available(iOS 26.0, *)) {
        result = [[NewInIOS26 new] describe];
    }

    // Assert
    XCTAssertEqualObjects(result, self.runningOniOS26OrNewer ? @"new" : @"plain");
}

- (void)testUncheckedUseIsAWarningNotAnError {
    // Act
    // warning: 'NewInIOS26' is only available on iOS 26.0 or newer
    //          [-Wunguarded-availability-new]
    // The class is compiled into this binary, so the send succeeds on any OS.
    NSString *result = [[NewInIOS26 new] describe];

    // Assert
    XCTAssertEqualObjects(result, @"new");
}

- (void)testPlatformUnavailableDoesNotApplyToOtherBuilds {
    // Arrange
    NSString *result = @"skipped";

    // Act
    // API_UNAVAILABLE(macos) on the declaration pairs with !TARGET_OS_OSX at
    // the call: the call is an error in a macOS build, and the preprocessor
    // is what keeps it out of one.
#if !TARGET_OS_OSX
    result = notOnMac();
#endif

    // Assert
    XCTAssertEqualObjects(result, @"called");
}

- (void)testDeprecatedStillRuns {
    // Act
    NSString *result = staleAPI();   // warning: 'staleAPI' is deprecated

    // Assert
    XCTAssertEqualObjects(result, @"stale");
    XCTAssertEqualObjects(freshAPI(), @"fresh");
}

- (void)testCompilationConditionsForThisBuild {
    // Arrange
    NSString *platform = @"other";
    BOOL hasUIKit = NO;
    BOOL isSimulator = NO;

    // Act
#if TARGET_OS_IOS
    platform = @"iOS";
#elif TARGET_OS_OSX
    platform = @"macOS";
#endif

#if __has_include(<UIKit/UIKit.h>)
    hasUIKit = YES;
#endif

#if TARGET_OS_SIMULATOR
    isSimulator = YES;
#endif

    // Assert
    XCTAssertEqualObjects(platform, @"iOS");
    XCTAssertTrue(hasUIKit);
    XCTAssertTrue(isSimulator);
}

- (void)testUntakenBranchIsNotEvenParsed {
    // Act
#if TARGET_OS_WATCH
    this is not Objective-C;
#endif

    // Assert
    XCTAssertTrue(YES);
}

@end
