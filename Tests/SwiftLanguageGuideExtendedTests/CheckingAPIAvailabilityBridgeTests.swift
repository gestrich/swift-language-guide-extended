import Foundation
import Testing

// How the Objective-C availability macros in Sources/SwiftLanguageGuideExtendedObjC
// import into Swift. Run on an iOS simulator with scripts/test-ios.sh.

#if canImport(SwiftLanguageGuideExtendedObjC)
import SwiftLanguageGuideExtendedObjC

struct CheckingAPIAvailabilityBridgeTests {
    private var runningOniOS26OrNewer: Bool {
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
    }

    @Test func importedClassNeedsACheck() {
        // Arrange
        var result = "plain"

        // Act
        if #available(iOS 26, *) {
            result = NewInIOS26().describe()
        }
        // Without the check, the same line is an error, where the Objective-C
        // call is a warning:
        // result = NewInIOS26().describe()
        // error: 'NewInIOS26' is only available in iOS 26.0 or newer

        // Assert
        #expect(result == (runningOniOS26OrNewer ? "new" : "plain"))
    }

    @Test func importedUnavailableMatchesTheSwiftAttribute() {
        // Arrange
        var result = "skipped"

        // Act
        #if !os(macOS)
        result = notOnMac()
        #endif

        // Assert
        #expect(result == "called")
    }

    @Test func importedDeprecatedStillRuns() {
        // Act
        let result = staleAPI()   // warning: 'staleAPI()' is deprecated

        // Assert
        #expect(result == "stale")
        #expect(freshAPI() == "fresh")
    }
}
#endif
