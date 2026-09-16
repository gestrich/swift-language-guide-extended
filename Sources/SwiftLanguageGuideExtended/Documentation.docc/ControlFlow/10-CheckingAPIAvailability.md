# Checking API Availability

Use an API that is newer than the oldest OS the app supports, and compile code
only on the platforms that have it.

## TODO

**Reviewed to: Start of The #available condition section**

- The mac 99 feels like an anti-pattern (see the paragraph below the list)
    Need clearer guidance on a pattern
        Consider some tip of Best Practice tip, Decision tip, Practical tip, anti-pattern, When to use, etc.
        The "choices" logic is probably the most important part of an article.
- Does API_AVAILABLE(ios(26.0)), the objc one, have an unavialbale version? How about @available(iOS 26.0, *)? #if os?
- Can you have types that don't exist at all for that platform? 
- What is something is marked unavailable AFTER a version? Can available check for it and will it compile?
- Consider defintions or concepts sections. 
- Consider diagrams in article
- Make writing-style global skill
- Add the actual swift language guide as a package dependency for reference

Notes on the mac 99 fix: `#available` and `#unavailable` both require a
version, so there is no run-time spelling of "not on macOS"; `#if !os(macOS)`
is the tool, and it is decided at compile time, so the skipped code never
type checks. The compiler gives no warning for `#available(macOS 99, *)`. Line
109 is illustrating clause selection, so keep the idea but use a real version
(`macOS 26` in an iOS build). Line 319 is showing that no version check can
reach an `unavailable` declaration; follow it with the `#if !os(macOS)` form
that does compile, and state the pairing: `@available(macOS, unavailable)` on
the declaration matches `#if !os(macOS)` at the call site. Link forward to the
`#if` section.

Poor Language:

"Swift has two ways to make that use legal" <- "that use" is obtuse
" Two settings describe that gap." <- Weird pattern

Each section should begin with an opener like what it does simply with an example before more details. That section coudl say when to use the pattern. Then each sub section provides deeper details.
Add information on newer API that like lets you check across platforms for same version
Does #unavailable also run on other platforms not specified?

## Contents

- <doc:#Overview>
- <doc:#The-available-condition>
- <doc:#The-available-attribute>
- <doc:#Objective-C>
- <doc:#if>

## Overview

Every build has two version numbers, and the article hinges on both.

The *deployment target* is the oldest OS the app runs on. A package manifest
spells it `.iOS(.v18)`. Xcode's General tab labels it Minimum Deployments,
and the Build Settings tab lists one per platform, such as iOS Deployment
Target. It is a floor with no ceiling: an app with a deployment target of
iOS 18 runs on iOS 18 and every version after it.

The *SDK* is the set of OS headers the compiler builds against. It ships
inside Xcode, one per release, and it is the newest OS the compiler knows
about. The Build Settings tab shows it as Base SDK, and `xcodebuild -showsdks`
lists the installed versions. An API introduced in iOS 26 is in the iOS 27
SDK, so the compiler can see it, but a device running iOS 18 does not have it.

The compiler rejects a use of an API newer than the deployment target, because
the app can run on a device where the symbol does not exist. Three constructs
deal with that, and they divide by when they are decided.

`#available` is a condition in an `if`, `guard`, or `while`, decided at run
time. Both branches compile against the SDK, and the OS version the app is
running on selects one. `#unavailable` is the same check inverted.

```swift
if #available(iOS 26, *) {
    view.glassEffect()
} else {
    view.background(.regularMaterial)
}
```

`@available` is an attribute on a declaration, and it moves the check to the
callers. Inside the body the version floor is the one named, so the body uses
the newer API without a check, and every caller has to satisfy that floor with
`#available` or an `@available` of its own. Its `unavailable` form forbids the
declaration on a platform, and no version check can reach it.

```swift
@available(iOS 26, *)
struct GlassLabel: View {
    var body: some View {
        Text("glass").glassEffect()
    }
}
```

`#if` is decided at build time and asks nothing about an API. It tests how the
build is configured — the platform, the architecture, the flags it was given —
and the compiler reads only the branch that matches. The other branch is never
type checked, so it can name modules and symbols this platform does not have.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/CheckingAPIAvailability", slice: "platformOnly")

## The #available condition

### Checking the OS version

`#available` is true when the OS the app is running on is at least the version
named. It goes where a `Bool` would go in an `if`, `guard`, or `while`, and the
branch it guards runs only on OS versions that have the API inside it.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/CheckingAPIAvailability", slice: "versionCheck")

The `guard` form leaves the rest of the function to the newer OS:

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/CheckingAPIAvailability", slice: "versionGuard")

Both branches are compiled, and the comparison happens each time the statement
runs, so one binary behaves differently on iOS 17 and on iOS 26.

### Platforms and the wildcard

An availability condition is a list of platform-and-version pairs, and it must
end in `*`. Each pair applies only to a build for that platform, and its
version is a minimum: `iOS 26` is satisfied on iOS 26 and on every later
version. The `*` covers every platform not named and means "the deployment
target", which is always satisfied. A version can carry minor and patch
components: `iOS 17.2.6` is valid, and is satisfied by iOS 17.2.6 and later.

```swift
if #available(iOS 26, macOS 26, *) { }

if #available(iOS 26) { }
// error: must handle potential future platforms with '*'
```

So in an iOS build, `#available(macOS 99, *)` always takes the then-branch: the
macOS clause does not apply to an iOS build, and the `*` applies instead.

### #unavailable

`#unavailable` runs its branch on OS versions *older* than the one named. Use
it when the only interesting code is the fallback. It takes no wildcard,
because one is always implicit:

```swift
if #unavailable(iOS 26) { installLegacyWorkaround() }

if #unavailable(iOS 26, *) { }
// error: platform wildcard '*' is always implicit in #unavailable
```

### The condition list

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

### Compile time and run time

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

### What the check does not validate

A version check does not validate the version against the SDK. `#available(iOS
99, *)` compiles cleanly. The version is a number compared at run time; the SDK
records only the version in which each *symbol* was introduced.

## The @available attribute

### What a condition cannot do

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

### Gating a declaration

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

### The long form

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

### Unavailable declarations

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

### The Swift language mode

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

### Back deployment

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

## Objective-C

### The run-time check

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

### The declaration macros

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

### Warning versus error

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

## #if

### Compilation conditions

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

### Toolchain and language mode

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

### What the compiler still checks

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

### Where a #if block can appear

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

### Modules a platform does not have

A version check answers when an API arrived on a platform, so no version number
makes UIKit importable in a macOS build:

```swift
import UIKit
// error: no such module 'UIKit'
```

`canImport` is the test for that. It asks about the module rather than about a
version, and it is resolved while the file is read, before the import is
attempted:

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/CheckingAPIAvailability", slice: "canImport")
