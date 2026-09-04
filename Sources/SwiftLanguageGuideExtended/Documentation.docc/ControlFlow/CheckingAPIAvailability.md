# Checking API Availability

Use an API that is newer than the oldest OS the app supports, and compile code
only on the platforms that have it.

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
floor inside it, and requires its callers to do the check.

```swift
if #available(iOS 26, *) {
    view.glassEffect()
} else {
    view.background(.regularMaterial)
}
```

Both answer the question "is this API new enough that some users will not have
it?" A third construct, `#if`, answers a different question — whether the
symbol exists on this platform at all. It is resolved while the file is read,
so it decides what goes into the binary rather than which compiled branch runs.

## The #available condition

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

An availability condition is a list of platform-and-version pairs, and it must
end in `*`. Each pair applies only to a build for that platform; the `*` covers
every platform not named and means "the deployment target", which is always
satisfied. A version can carry minor and patch components: `iOS 17.2.6` is
valid.

```swift
if #available(iOS 26, macOS 26, *) { }

if #available(iOS 26) { }
// error: must handle potential future platforms with '*'
```

So in an iOS build, `#available(macOS 99, *)` always takes the then-branch: the
macOS clause does not apply to an iOS build, and the `*` applies instead.

`#unavailable` runs its branch on OS versions *older* than the one named. Use
it when the only interesting code is the fallback. It takes no wildcard,
because one is always implicit:

```swift
if #unavailable(iOS 26) { installLegacyWorkaround() }

if #unavailable(iOS 26, *) { }
// error: platform wildcard '*' is always implicit in #unavailable
```

## Compile time and run time

Inside the then-branch the compiler treats the checked version as the
deployment target, so newer APIs type-check there; the run-time test only
selects the branch that executes.

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

## @available on a declaration

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

`@available` gates a declaration. It applies to types, functions, properties,
enum cases, extensions, and protocol conformances. The declaration is always
compiled and always shipped; the attribute changes the version floor inside it
and the rules at its call sites.

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

## The long form of @available

One platform, keyword arguments, and no `*`. It says more than "introduced in":

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

`unavailable` makes a declaration impossible to call. Name a platform and only
builds for that platform are affected. It carries no version, so unlike
`obsoleted:` there is nothing for a deployment target or an `#available` check
to reach; the declaration is still compiled and shipped, and the attribute
rejects the calls.

```swift
@available(macOS, unavailable)
func notOnMac() { }

notOnMac()
// error: 'notOnMac()' is unavailable in macOS

if #available(macOS 99, *) { notOnMac() }
// error: 'notOnMac()' is unavailable in macOS
```

This is the Swift spelling of `API_UNAVAILABLE`, and how the SDK marks an API
that a platform does not have at all.

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
library, but not to types or stored properties, whose layout is fixed by the
OS.

```swift
extension Box {
    @backDeployed(before: iOS 26.0)
    public func doubled() -> Int { n * 2 }
}
```

## Availability in Objective-C

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

The severity differs. Using an API newer than the deployment target without a
check is an error in Swift and a warning in Objective-C:

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

## Conditional compilation with #if

`#if` is resolved as the file is read. The branch that matches is compiled, and
the branches that do not match are removed before type checking. Nothing about
it survives to run time.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/CheckingAPIAvailability", slice: "platform")

A compilation condition is built from `!`, `&&`, and `||` over tests such as
`os(...)`, `arch(...)`, `canImport(...)`, and `targetEnvironment(...)`. The
block is delimited by `#if` and `#endif`, with no braces.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/CheckingAPIAvailability", slice: "operators")

A bare identifier tests a flag the build passes in — `swiftc -D DEBUG`, or
Xcode's `SWIFT_ACTIVE_COMPILATION_CONDITIONS` build setting, which is where
`DEBUG` comes from in a stock Xcode project. The name has no value attached; it
is either defined for this build or it is not.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/CheckingAPIAvailability", slice: "flags")

`compiler(>=6.0)` is true when the compiler building the file is at least that
version. `swift(>=6.0)` is true when the language mode in effect is at least
that version, which is set by the package manifest or the build setting and can
be older than the compiler. Neither says anything about the machine the code
will run on. They exist for source that has to build across several toolchains —
a package supporting more than one Swift release, say.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/CheckingAPIAvailability", slice: "toolchain")

For that job, `hasFeature(...)` and `hasAttribute(...)` are usually the better
test. They ask whether the compiler enables an upcoming language feature or
understands an attribute, which is the question a version number is being used
to approximate.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/CheckingAPIAvailability", slice: "capabilities")

Code in a branch that is not taken has to be lexically and syntactically valid
Swift, because the compiler still parses the whole file. It does not have to
resolve: a call to a function that exists on no platform compiles fine as long
as it is inside a branch that is not taken.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/CheckingAPIAvailability", slice: "notTypeChecked")

A syntax error is caught wherever it is:

```swift
#if os(watchOS)
let x = = =
#endif
// error: expected initial value after '='
```

> Note: In a playground, `#if` blocks behave differently from a compiled target,
> and none of the branches above print. Test conditional compilation in a real
> target.

## Where a #if block can appear

Because `#if` selects text rather than statements, it can wrap anything a file
can contain — an import, a type, a function, a property. That is how one source
file supplies a different implementation of the same type per platform.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/CheckingAPIAvailability", slice: "declarations")

An availability condition cannot do this, for the reason the previous sections
gave: it is part of a statement, and a statement holds no declarations.
`@available` gates a declaration by version; `#if` gates one by platform.

A `#if` may appear between the members of a chained call, so a modifier can be
applied on one platform and skipped on another without repeating the whole
expression.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/CheckingAPIAvailability", slice: "memberChain")

The branch holds a suffix of the chain, so each branch has to produce the same
type for the members that follow it.

## What a version check does not do

**It does not validate the version against the SDK.** `#available(iOS 99, *)`
compiles cleanly. The version is a number compared at run time; the SDK records
only the version in which each *symbol* was introduced.

**It cannot reach a symbol the platform does not have at all.** A version check
answers when an API arrived on a platform, so no version number makes UIKit
importable in a macOS build:

```swift
import UIKit
// error: no such module 'UIKit'
```

`canImport` is the test for that. It asks about the module rather than about a
version, and it is resolved while the file is read, before the import is
attempted:

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/CheckingAPIAvailability", slice: "canImport")
