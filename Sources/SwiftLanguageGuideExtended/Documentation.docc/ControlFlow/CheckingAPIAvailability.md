# Checking API Availability

Run an API that is newer than the oldest OS the app supports, without crashing
on the devices that do not have it.

## Overview

An app is built against one SDK and runs on many OS versions. Two settings
describe that gap. The *deployment target* is the oldest OS the build is allowed
to run on. The *SDK* is the set of declarations the code compiles against — the
headers and `.swiftinterface` files inside the selected Xcode.

The compiler knows the version each SDK declaration was introduced in, and
rejects any use of a declaration newer than the deployment target, because that
build can run on a device where the symbol does not exist:

```swift
Text("hi").glassEffect()
// error: 'glassEffect(_:in:)' is only available in iOS 26.0 or newer
// note: add 'if #available' version check
```

Swift has two ways to make that use legal, and they are different kinds of
language construct. `#available` is a condition: it belongs to the condition
list of an `if`, `guard`, or `while`, and the version is compared at run time.
`@available` is an attribute: it attaches to a declaration, raises the version
floor inside it, and pushes the check out to its callers.

```swift
if #available(iOS 26, *) {
    view.glassEffect()
} else {
    view.background(.regularMaterial)
}
```

Both answer the question "is this API new enough that some users will not have
it". A third construct, `#if`, answers a different question — whether the symbol
exists on this platform at all — and is resolved while the file is read rather
than at run time. See <doc:ConditionalCompilation>.

## An availability condition is not an expression

Swift's `if`, `guard`, and `while` take a comma-separated list of conditions,
and the grammar allows four kinds:

| Kind | Example |
| --- | --- |
| A `Bool` expression | `flag` |
| An optional binding | `let n = optionalValue` |
| A `case` condition | `case .a(let n) = value` |
| An availability condition | `#available(iOS 26, *)` |

Only the first kind is an expression. An availability condition produces no
value, so it cannot be stored, negated, or joined with `||`:

```swift
let supported = #available(iOS 26, *)
// error: #available may only be used as condition of an 'if', 'guard'
//        or 'while' statement

if #available(iOS 26, *) || flag { }
// error: expected '{' after 'if' condition

if !#available(iOS 26, *) { }
// error: #available cannot be used as an expression, did you mean to use
//        '#unavailable'?
```

Despite the `#`, it is not a macro. A freestanding macro expands into an
expression, a declaration, or a code item, and none of those is a condition.
The three availability conditions the compiler reserves are `#available`,
`#unavailable`, and `#_hasSymbol`, the check for a weakly linked symbol.

Conditions combine only by comma, which means AND, and the four kinds mix
freely in one list.

```swift
if flag, let name = candidateName, #available(iOS 26, *) { }
```

## The wildcard is required

The condition is a list of platform-and-version pairs, and it must end in `*`.
Each pair applies only to a build for that platform; the `*` covers every
platform not named and means "the deployment target", which is always satisfied.
A version can carry minor and patch components: `iOS 17.2.6` is valid.

```swift
if #available(iOS 26, macOS 26, *) { }

if #available(iOS 26) { }
// error: must handle potential future platforms with '*'
```

So in an iOS build, `#available(macOS 99, *)` always takes the then-branch: the
macOS clause does not apply to an iOS build, and the `*` decides.

## The compiler raises the version floor inside the branch

Inside the then-branch the compiler treats the checked version as the deployment
target, so newer APIs type-check there. That compile-time effect makes the newer
API legal; the run-time test only decides which branch executes.

```swift
if #available(iOS 26, *) {
    Text("guarded").glassEffect()   // legal here
} else {
    Text("plain").glassEffect()
    // error: 'glassEffect(_:in:)' is only available in iOS 26.0 or newer
}
```

Both branches are compiled and shipped. The else-branch keeps the project's
deployment target.

In a `guard`, the raised floor applies to the code after the statement rather
than to a nested block, which keeps the newer path unindented:

```swift
func label() -> AnyView {
    guard #available(iOS 26, *) else {
        return AnyView(Text("plain"))
    }
    return AnyView(Text("glass").glassEffect())
}
```

## The inverse check runs on older systems

`#unavailable` runs its branch on OS versions *older* than the one named. Use it
when the only interesting code is the fallback. It takes no wildcard, since
there is nothing for the wildcard to decide:

```swift
if #unavailable(iOS 26) { installLegacyWorkaround() }

if #unavailable(iOS 26, *) { }
// error: platform wildcard '*' is always implicit in #unavailable
```

## A condition cannot gate a declaration

A condition is part of a statement, and a statement holds no declarations. The
failure looks different depending on where the attempt is made. A type body
does not allow statements:

```swift
struct Badge {
    if #available(iOS 26, *) { func glassBody() {} }
}
// error: expected declaration
```

At file scope in an ordinary source file, it is `error: statements are not
allowed at the top level`. Inside a function it compiles, because a local
declaration is legal in any block, but it gates nothing — the declaration goes
out of scope at the closing brace:

```swift
func outer() {
    if #available(iOS 26, *) {
        func inner() {}
        inner()   // fine
    }
    inner()       // error: cannot find 'inner' in scope
}
```

## @available attaches the constraint to a declaration

`@available` applies to types, functions, properties, enum cases, extensions,
and protocol conformances. The declaration is always compiled and always
shipped; what changes is the version floor inside it and the rules at its call
sites.

```swift
@available(iOS 26, *)
struct GlassLabel: View {
    var body: some View {
        Text("glass").glassEffect()   // the floor in here is iOS 26
    }
}

_ = GlassLabel()
// error: 'GlassLabel' is only available in iOS 26 or newer
// note: add 'if #available' version check

if #available(iOS 26, *) { _ = GlassLabel() }   // fine
```

The syntax matches `#available` — platform-and-version pairs ending in `*`, and
the `*` is required. A clause naming a platform this build is not for has no
effect: `@available(macOS 26, *)` constrains nothing in an iOS build, and the
function is callable there with no check.

## The long form deprecates, obsoletes, and renames

One platform, keyword arguments, and no `*`. This is the form that says more
than "introduced in":

```swift
@available(iOS, introduced: 13.0, deprecated: 16.0, obsoleted: 30.0,
           message: "Use freshAPI() instead.")
func oldAPI() { }
```

`deprecated:` produces a warning at the call site once the deployment target
reaches that version; the code still compiles and runs. `obsoleted:` produces an
error, and also only once the deployment target reaches the named version — at a
deployment target of iOS 17, `obsoleted: 30.0` is not yet in force. `message:`
is appended to the diagnostic, and `renamed:` names the replacement, which Xcode
offers as a fix-it:

```swift
@available(*, deprecated, renamed: "freshAPI")
func staleAPI() { }

staleAPI()
// warning: 'staleAPI()' is deprecated: renamed to 'freshAPI'
```

With `*` as the platform, the constraint applies everywhere:

```swift
@available(*, unavailable, message: "This one never ships.")
func neverAvailable() { }
// error: 'neverAvailable()' is unavailable: This one never ships.

@available(*, noasync, message: "blocks the thread")
func blocking() { }

func caller() async { blocking() }
// error: global function 'blocking' is unavailable from asynchronous
//        contexts; blocks the thread
```

That last one is an error in the Swift 6 language mode and a warning in the
Swift 5 mode.

A version with no platform gates on the Swift language mode — the
`SWIFT_VERSION` build setting — rather than on any OS or on the compiler
version:

```swift
@available(swift 6.0)
func requiresSwift6LanguageMode() { }
// building the same file with -swift-version 5:
// error: 'requiresSwift6LanguageMode()' is unavailable in Swift
// note: 'requiresSwift6LanguageMode()' was introduced in Swift 6.0
```

`@backDeployed(before:)` answers the reverse question — how to run a newer API
on an older system instead of gating it. It compiles a copy of the function's
body into every client that uses it, so callers on OS versions older than the
one the API shipped in run the copy rather than the version in the OS. It
applies to functions, methods, subscripts, and computed properties in a
library, but not to types or stored properties, whose layout the OS owns.

```swift
extension Box {
    @backDeployed(before: iOS 26.0)
    public func doubled() -> Int { n * 2 }
}
```

## Both branches ship in the binary

The difference between a run-time check and a compile-time one is visible in the
compiled product. Two functions, one of each:

```swift
public func runtimeCheck() {
    if #available(macOS 26, *) { print("TAKEN_ON_NEW_OS") }
    else { print("TAKEN_ON_OLD_OS") }
}

public func compileTimeCheck() {
#if os(iOS)
    print("COMPILED_FOR_IOS")
#else
    print("COMPILED_FOR_MACOS")
#endif
}
```

Built for macOS with optimization on, both `#available` branches are present and
only one `#if` branch is:

```
$ swiftc -O -target arm64-apple-macos14.0 \
      -emit-library -o lib.dylib checks.swift
$ strings lib.dylib | grep -E 'TAKEN|COMPILED'
TAKEN_ON_OLD_OS
TAKEN_ON_NEW_OS
COMPILED_FOR_MACOS
```

The run-time part of the mechanism is a single call:

```
$ nm -u lib.dylib | grep VersionAtLeast
_$ss26_stdlib_isOSVersionAtLeastyBi1_Bw_BwBwtF
```

`_stdlib_isOSVersionAtLeast` asks the running OS for its version and returns a
boolean. Compile the same file with a deployment target of macOS 26 or later and
the call disappears, because the condition is then a constant the optimizer can
fold.

## Objective-C warns where Swift refuses to compile

Objective-C has the same checks with different spellings. The run-time check is
`@available`, with the same required `*` and the same raised version floor
inside the block. Clang lowers it to a call to `__builtin_available`.

```objc
if (@available(iOS 26.0, *)) {
    NewInIOS26 *thing = [NewInIOS26 new];
}
```

There is no `#unavailable`, and none is needed: here `@available` is an ordinary
boolean condition, so `if (!@available(iOS 26.0, *))` is legal.

Declarations take macros rather than an attribute — `API_AVAILABLE(ios(26.0))`,
`API_DEPRECATED("Use NewInIOS26 instead.", ios(13.0, 16.0))`, and
`API_UNAVAILABLE(watchos)`, matching `@available`'s introduced, deprecated, and
unavailable forms. The older `NS_AVAILABLE_IOS(10_0)` spellings mean the same
thing and fill older headers.

```objc
API_AVAILABLE(ios(26.0))
@interface NewInIOS26 : NSObject
- (BOOL)helloWorld API_AVAILABLE(ios(26.0));
@end
```

The difference that matters is the severity. Using an API newer than the
deployment target without a check is an error in Swift and a warning in
Objective-C:

```objc
return [[NewInIOS26 new] describe];
// warning: 'NewInIOS26' is only available on iOS 26.0 or newer
//          [-Wunguarded-availability-new]
```

The build succeeds and the app ships; on an older OS the class is missing and
the message send crashes. `-Werror=unguarded-availability-new` promotes the
warning, giving Objective-C the behavior Swift has by default.
`API_UNAVAILABLE` is the exception that is already an error.

Availability crosses the bridge. A class marked `API_AVAILABLE(ios(26.0))` is
imported into Swift as `@available(iOS 26.0, *)`, and Swift then applies its own
rule — a missing check is an error, even though the same call from Objective-C
is only a warning.

## What a version check does not do

**It does not validate the version against the SDK.** `#available(iOS 99, *)`
compiles cleanly. The version is a number compared at run time; the SDK records
only the version in which each *symbol* was introduced.

**It cannot reach a symbol the platform does not have at all.** A version check
answers when an API arrived on a platform, so no version of it rescues UIKit in
a macOS build:

```swift
import UIKit
// error: no such module 'UIKit'
```

That is a job for `#if canImport(UIKit)`, which is resolved while the file is
read. See <doc:ConditionalCompilation>.
