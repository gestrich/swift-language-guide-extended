# Deferred actions

Schedule a block to run when execution leaves the current scope, whichever way
it leaves.

## Overview

A `defer` block runs at the end of the scope that contains it, no matter which
statement ends that scope — the closing brace, a `return`, a `break`, a
`continue`, or a thrown error. Its use is cleanup that has to happen on every
path.

Without it, each exit path carries its own copy of the cleanup, and a `guard`
added later — see <doc:EarlyExit> — is a new place to forget it.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/DeferredActions", slice: "withoutDefer")

A `defer` written next to the thing it cleans up covers every path, including
ones added later.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/DeferredActions", slice: "withDefer")

Any block is a scope, so this works in a function, an `if`, a `do`, or a loop
body — where the block runs at the end of each pass.

## The block reads values when it runs rather than when it is written

A `defer` captures the surrounding scope the way a closure does. The values it
prints are the ones in effect at the end of the scope.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/DeferredActions", slice: "readsAtExecution")

## The statement has to be reached to be scheduled

A `defer` is scheduled when execution runs over it rather than when the scope
is entered. A path that leaves before reaching it never registers it.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/DeferredActions", slice: "mustBeReached")

The empty string takes the `continue` before the `defer` is reached, so nothing
is closed for it.

## Deferred blocks run in reverse order

Several `defer` blocks in one scope run last-registered first, which matches how
resources are usually released: the last thing acquired is the one that other
things do not depend on.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/DeferredActions", slice: "reverseOrder")

## It runs for a thrown error, but not for a crash

Throwing leaves the scope, so the deferred block runs before the error reaches
the caller. This is what makes `defer` the right place for cleanup in a throwing
function.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/DeferredActions", slice: "runsOnThrow")

Stopping the process is different. `fatalError`, `preconditionFailure`, and a
trap such as an out-of-bounds subscript end the process without unwinding, so no
deferred block runs. Cleanup that must happen even then belongs somewhere the
operating system enforces, not in a `defer`.
