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
build could land on a device where the symbol does not exist:

```swift
Text("hi").glassEffect()
// error: 'glassEffect(_:in:)' is only available in iOS 26.0 or newer
// note: add 'if #available' version check
```

An availability condition makes the use legal. It is a fourth kind of condition
in the `if`, `guard`, and `while` grammar, alongside boolean expressions,
optional bindings, and `case` conditions:

```swift
if #available(iOS 26, *) {
    view.glassEffect()
} else {
    view.background(.regularMaterial)
}
```

## The wildcard is required

The condition is a list of platform-and-version pairs, and it must end in `*`.
Each pair applies only to a build for that platform; the `*` covers every
platform not named and means "the deployment target", which is always satisfied.

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

## The guard form covers the rest of the function

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

The two also cannot be written as expressions. An availability condition
produces no value, so it cannot be stored, negated, or joined with `||` — only
comma-separated with other conditions, which means AND.

```swift
let supported = #available(iOS 26, *)
// error: #available may only be used as condition of an 'if', 'guard'
//        or 'while' statement
```

## What the check does not do

**It does not validate the version against the SDK.** `#available(iOS 99, *)`
compiles cleanly. The version is a number compared at run time; the SDK records
only the version in which each *symbol* was introduced.

**It cannot reach a symbol the platform does not have at all.** A version check
answers when an API arrived on a platform. It cannot make a symbol exist on a
platform that never had it, so no version check rescues this in a macOS build:

```swift
import UIKit
// error: no such module 'UIKit'
```

That is a job for `#if canImport(UIKit)`, which is resolved while the file is
read rather than at run time. See <doc:ConditionalCompilation>.

**It cannot gate a declaration.** A condition belongs to a statement, and a
statement holds no declarations. Written in a type body it is
`error: expected declaration`; written inside a function it compiles, but the
declaration goes out of scope at the closing brace and nothing is gated. The
`@available` attribute is the tool for a declaration.
