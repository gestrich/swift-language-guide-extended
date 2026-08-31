// snippet.hide
// Examples for the "Conditional compilation" article.
// snippet.show

// snippet.platform
#if os(macOS)
print("Built for macOS")
#elseif os(iOS)
print("Built for iOS")
#else
print("Built for some other platform")
#endif
// snippet.end

// snippet.operators
#if !os(macOS)
print("Not macOS")
#endif

#if os(macOS) || os(iOS)
print("macOS or iOS")
#endif
// snippet.end

// snippet.notTypeChecked
#if os(watchOS)
nonExistentFunction()
#endif
// snippet.end

// snippet.canImport
#if canImport(UIKit)
import UIKit
#endif
// snippet.end

// snippet.declarations
#if os(macOS)
struct Chrome {
    func describe() {
        print("windows and a menu bar")
    }
}
#else
struct Chrome {
    func describe() {
        print("a single full-screen window")
    }
}
#endif

Chrome().describe()
// snippet.end

// snippet.toolchain
#if compiler(>=6.0)
print("Compiled by Swift 6.0 or newer")
#endif

#if swift(>=6.0)
print("Compiling in Swift 6 language mode or newer")
#endif
// snippet.end

// snippet.flags
#if DEBUG
print("Extra logging is on")
#else
print("Release build")
#endif
// snippet.end

// snippet.capabilities
#if hasFeature(StrictConcurrency)
print("Strict concurrency checking is on")
#endif

#if hasAttribute(retroactive)
print("The compiler understands @retroactive")
#endif
// snippet.end

// snippet.memberChain
struct Panel {
    func padded() -> Panel { self }
    func describe() { print("a panel") }
}

let panel = Panel()
    #if os(macOS)
    .padded()
    #endif

panel.describe()
// snippet.end
