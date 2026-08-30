# If statements

Choose between blocks of code on a Boolean condition.

## Overview

An `if` statement runs a block when its condition is true, and an optional chain
of `else if` and `else` clauses covers the other cases. The braces are part of
the grammar rather than a style choice, so a single-statement body still needs
them.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/IfStatements", slice: "basic")

Dropping them is a parse error:

```swift
if ready print("go")
// error: expected '{' after 'if' condition
```

## A final else is optional, even after else if

A chain that ends on `else if` is complete on its own. When no branch matches,
nothing runs.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/IfStatements", slice: "noElse")

That changes once the `if` is used as an expression, where every path has to
produce a value. See <doc:ConditionalExpressions>.

## The condition must be a Bool

Swift has no truthiness. A number is not a condition, and neither is an
optional; both are rejected with a diagnostic naming the test to write instead.

```swift
if itemCount { }
// error: type 'Int' cannot be used as a boolean; test for '!= 0' instead

if shopper { }
// error: optional type 'String?' cannot be used as a boolean;
//        test for '!= nil' instead
```

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/IfStatements", slice: "testExplicitly")

An optional usually wants `if let` rather than a `!= nil` test, so that the
unwrapped value is available in the body.

## Assigning from branches names the target once per branch

A common use of an `if` statement is to give one variable a value. Declaring the
constant without a value keeps the compiler's initialization check, which
reports any path that fails to assign.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/IfStatements", slice: "assignFromBranches")

The check catches a missing branch, but it reports it at the first *use* of the
constant rather than at the `if`:

```swift
let advice: String
if temperatureInFahrenheit >= 86 {
    advice = "Wear sunscreen."
}
print(advice)
// error: constant 'advice' used before being initialized
```

An `if` expression names the target once and reports a gap at the declaration.
That form is in <doc:ConditionalExpressions>.
