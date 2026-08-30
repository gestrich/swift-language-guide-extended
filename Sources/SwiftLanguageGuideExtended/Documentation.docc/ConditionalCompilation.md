# Conditional compilation

Include or exclude code while the file is being compiled, based on the platform,
the compiler, or the language mode.

## Overview

`#if` is resolved as the file is read. The branch that matches is compiled, and
the branches that do not match are removed before type checking. Nothing about
it survives to run time, which is the difference between `#if` and an
availability condition: `#if` decides what is in the binary, and `#available`
decides which of two compiled paths executes on the device.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ConditionalCompilation", slice: "platform")

Use `#if` when the code cannot exist on a platform. Use `#available` when the
code exists but arrived in a later OS version. See
<doc:CheckingAPIAvailability>.

## An inactive branch is parsed but not type checked

Code in a branch that is not taken has to be lexically and syntactically valid
Swift, because the compiler still parses the whole file. It does not have to
resolve: a call to a function that exists on no platform compiles fine as long
as it is inside a branch that is not taken.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ConditionalCompilation", slice: "notTypeChecked")

A syntax error is caught wherever it is:

```swift
#if os(watchOS)
let x = = =
#endif
// error: expected initial value after '='
```

That is what makes `#if` the tool for a symbol that a platform does not have.
No availability check can rescue `import UIKit` in a macOS build, because there
is no version of macOS that has the module. `canImport` tests for the module
itself:

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ConditionalCompilation", slice: "canImport")

## The condition uses operators, and takes no braces

A compilation condition is built from `!`, `&&`, and `||` over tests such as
`os(...)`, `arch(...)`, `canImport(...)`, and `targetEnvironment(...)`. The
block is delimited by `#if` and `#endif`, with no braces.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ConditionalCompilation", slice: "operators")

## A block can hold declarations

Because `#if` selects text rather than statements, it can wrap anything a file
can contain — an import, a type, a function, a property. That is how one source
file supplies a different implementation of the same type per platform.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ConditionalCompilation", slice: "declarations")

An availability condition cannot do this. It is part of a statement, and a
statement holds no declarations.

## compiler and swift test the toolchain rather than the operating system

`compiler(>=6.0)` is true when the compiler building the file is at least that
version. `swift(>=6.0)` is true when the language mode in effect is at least
that version, which is set by the package manifest or the build setting and can
be older than the compiler.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ConditionalCompilation", slice: "toolchain")

Neither says anything about the machine the code will run on. They exist for
source that has to build across several toolchains — a package supporting more
than one Swift release, say — rather than for anything a user of the app would
notice.

> Note: In a playground, `#if` blocks behave differently from a compiled target,
> and none of the branches above print. Test conditional compilation in a real
> target.
