import Foundation
import SwiftUI
import Testing

// Experiments for the "Checking API Availability" article. Run them on an iOS
// simulator with scripts/test-ios.sh; on macOS the platform checks below flip.

@available(iOS 26, *)
private struct GlassLabel: View {
    var body: some View {
        Text("glass").glassEffect()
    }
}

@available(macOS, unavailable)
private func notOnMac() -> String { "called" }

@available(*, deprecated, renamed: "freshAPI")
private func staleAPI() -> String { "stale" }

private func freshAPI() -> String { "fresh" }

struct CheckingAPIAvailabilityTests {
    private var runningOniOS26OrNewer: Bool {
        ProcessInfo.processInfo.operatingSystemVersion.majorVersion >= 26
    }

    @Test func availableAgreesWithProcessInfo() {
        // Arrange
        var taken = false

        // Act
        if #available(iOS 26, *) { taken = true }

        // Assert
        #expect(taken == runningOniOS26OrNewer)
    }

    @Test func unavailableIsTheComplement() {
        // Arrange
        var taken = false

        // Act
        if #unavailable(iOS 26) { taken = true }

        // Assert
        #expect(taken == !runningOniOS26OrNewer)
    }

    @Test func wildcardCoversPlatformsNotNamed() {
        // Arrange
        var taken = false

        // Act
        if #available(macOS 99, *) { taken = true }

        // Assert
        #expect(taken)
    }

    @Test func guardRaisesTheFloorAfterIt() {
        // Arrange
        func label() -> String {
            guard #available(iOS 26, *) else { return "plain" }
            _ = GlassLabel()
            return "glass"
        }

        // Act
        let result = label()

        // Assert
        #expect(result == (runningOniOS26OrNewer ? "glass" : "plain"))
    }

    @Test func platformUnavailableDoesNotApplyToOtherBuilds() {
        // Act
        let result = notOnMac()

        // Assert
        #expect(result == "called")
    }

    @Test func deprecatedStillRuns() {
        // Act
        let result = staleAPI()   // warning: 'staleAPI()' is deprecated

        // Assert
        #expect(result == "stale")
    }

    @Test func compilationConditionsForThisBuild() {
        // Arrange
        var platform = "other"
        var hasUIKit = false
        var isSimulator = false

        // Act
        #if os(iOS)
        platform = "iOS"
        #elseif os(macOS)
        platform = "macOS"
        #endif

        #if canImport(UIKit)
        hasUIKit = true
        #endif

        #if targetEnvironment(simulator)
        isSimulator = true
        #endif

        // Assert
        #expect(platform == "iOS")
        #expect(hasUIKit)
        #expect(isSimulator)
    }

    @Test func untakenBranchIsNotTypeChecked() {
        // Act
        #if os(watchOS)
        nonExistentFunction()
        #endif

        // Assert
        #expect(Bool(true))
    }
}
