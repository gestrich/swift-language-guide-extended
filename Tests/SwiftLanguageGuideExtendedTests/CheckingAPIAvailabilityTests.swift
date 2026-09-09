import Foundation
import Testing

// Experiments for the "Checking API Availability" article. Run them on an iOS
// simulator with scripts/test-ios.sh.

struct CheckingAPIAvailabilityTests {
    @Test func availableAgreesWithProcessInfo() {
        // Arrange
        let runningOniOS26OrNewer =
            ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
        var taken = false

        // Act
        if #available(iOS 26, *) { taken = true }

        // Assert
        #expect(taken == runningOniOS26OrNewer)
    }
}
