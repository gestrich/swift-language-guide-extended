import Foundation
import Testing
#if os(iOS)
import UIKit
#endif

// Experiments for the "Checking API Availability" article. Run them on an iOS
// simulator with scripts/test-ios.sh.

struct CheckingAPIAvailabilityTests {
    @Test func availableAgreesWithProcessInfo() {
        // Arrange
//        let runningOniOS26OrNewer =
//            ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
//        var taken = false
//
//        // Act
//        if #available(iOS 26, *) {
//            UIDevice.current.userInterfaceIdiom
//        }
//        
//        if #available(macOS 99, *) {
//            UIDevice.current.userInterfaceIdiom
//        }
//
//        // Assert
//        #expect(taken == runningOniOS26OrNewer)
    }
}

// #available: Symbols must compile on platform you will build on but mya not be avialble at user runtime. Use for APIs that are avialble on different verions of OS
// #unavailable: Use for APIs that
// #if os: Conditinoally compile. Use for either things that should not happen on platofrm at all, like if there are refernefces since that don't exist on that platform.
