# Early exit

Use guard to handle the cases a function cannot proceed with, and leave the rest
of the body at one level of indentation.

## Overview

A `guard` states a condition the code after it depends on. When the condition
fails, the `else` block runs and has to leave the current scope. Anything a
`guard` binds stays in scope for the rest of the enclosing block, where an
`if let` binding is confined to its own body.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/EarlyExit", slice: "guardBasic")

The same function written with `if let` nests one level for each condition, and
puts the failure handling further from the condition that caused it.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/EarlyExit", slice: "nestedIfLet")

## The else block must leave the scope

Falling off the end of the `else` block is an error, because the code after the
`guard` would then run with the condition unmet:

```swift
guard let rawTemperature else {
    print("No reading")
}
// error: 'guard' body must not fall through, consider using a 'return' or
//        'throw' to exit the scope
```

`return` and `throw` are the usual exits. Inside a loop, `continue` and `break`
work too — see <doc:ControlTransferStatements> — which makes `guard` a way to
skip an element without nesting the body.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/EarlyExit", slice: "guardInLoop")

A call returning `Never` also satisfies the requirement, since it does not come
back.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/EarlyExit", slice: "preconditionFailure")

## assert satisfies the else block in debug builds only

`assert(false, "…")` compiles as a `guard` exit with assertions enabled, because
the optimizer sees the literal condition and inlines the call down to something
that does not return. Build the same file with `-O`, where assertions are
removed, and the exit disappears:

```swift
guard let rawTemperature else {
    assert(false, "missing")
}
// (debug) compiles
// (-O) error: 'guard' body must not fall through, consider using a
//             'return' or 'throw' to exit the scope
```

A non-literal condition fails in both, since nothing tells the compiler the call
cannot return:

```swift
guard let rawTemperature else {
    assert(isOptional, "missing")
}
// error: 'guard' body must not fall through, consider using a 'return' or
//        'throw' to exit the scope
```

Use `preconditionFailure` or `fatalError` when the intent is to stop. Both are
declared as returning `Never`, so they satisfy the `guard` in every build
configuration, and both keep working in release.
