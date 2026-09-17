// SwiftPM requires at least one source file in a target. This package's content
// is the DocC catalog in Documentation.docc, so this type is deliberately
// internal — a public symbol would appear in the rendered navigation.
enum SwiftLanguageGuideExtendedPlaceholder {}

@available(iOS 26, *)
func myFunction() {
    
}

// I don't understanding this note:

/*
 Forbid a declaration on one platform, or on all of them with *. Every call is a compile error; no version check can reach it.
 
 ^What does it mean forbid all with * ?
 Does unavialbale flip the entire statement?
 */
@available(macOS, unavailable)
func anotherFunction() {
    
}

// Add notes on this form of anyAppleOS
// Resaerch waht it does first and which veriosn of xcode this is available
@available(anyAppleOS 26, *)
func evenBetterFunction() {
    
}

@available(macOS, *, unavailable)
func evenBetterFunction1() {
    
}
