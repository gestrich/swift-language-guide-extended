# Conditional expressions

Use `if` and `switch` as expressions that produce a value, rather than as
statements that branch to code.

## Overview

An `if` *statement* branches to code, as in <doc:IfStatements>. Its branches may contain expressions, but
the statement itself produces no value. An `if` *expression* produces one: each
branch is a single expression, and the value of the branch that runs becomes the
value of the whole `if`. Both forms are spelled the same way; the position
decides which one it is.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/ConditionalExpressions", slice: "ifExpression")

`switch` works as an expression on the same terms, with each case supplying a
value. A function whose whole body is one expression needs no `return`, so the
two combine well. The statement form is in <doc:SwitchStatements>.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/ConditionalExpressions", slice: "switchExpression")

Both were added in Swift 5.9. Reach for them when every branch feeds one
assignment or one return.

## Every path must produce a value

An `if` expression needs an unconditional `else`. Ending the chain on `else if`
leaves a path with no value:

```swift
let advice = if temperature <= 32 {
    "cold"
} else if temperature >= 86 {
    "hot"
}
// error: 'if' must have an unconditional 'else' to be used as expression
```

A `switch` expression inherits the exhaustiveness rule it already has as a
statement, so it needs a `default` unless the cases cover the type.

The statement form is checked too, but later and further away. A `let` declared
without a value is caught by the initialization check at its first *use*, and
that check only exists because the declaration has no value yet. Give the
variable a starting value and the check is gone:

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/ConditionalExpressions", slice: "silentTypo")

Assigning `unrelatedAdvice` in one branch and `typoAdvice` in the other compiles
without a diagnostic, and `typoAdvice` keeps its placeholder. The expression form
removes that hazard because the target is named once, ahead of the branches.

## Each branch is a single expression

A branch holds one expression and nothing else. Setup lines before the value are
rejected:

```swift
let advice = if temperature <= 32 {
    "cold"
} else {
    print("done")
    "warm"
}
// error: non-expression branch of 'if' expression may only end with a 'throw'
```

`return`, `break`, and `continue` cannot appear inside a branch either, because
they transfer control out of an expression that is still being evaluated:

```swift
let advice = if temperature > 85 { "hot" } else { continue }
// error: cannot use 'continue' to transfer control out of 'if' expression
```

As the first error hints, `throw` is the exception. A throwing branch produces no
value, so it may do work first as long as it ends in `throw`. The remaining
branches determine the type of the expression.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/ConditionalExpressions", slice: "throwingBranch")

A call that returns `Never`, such as `fatalError()`, also stands in for a value —
but it gets no such exemption and has to be the single expression in its branch.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/ConditionalExpressions", slice: "neverBranch")

A `switch` expression has one more escape: `fallthrough`, where the case fallen
into supplies the value.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/ConditionalExpressions", slice: "switchFallthrough")

When a branch needs real setup work, the pre-5.9 form still applies: an
immediately invoked closure has no single-expression limit, and it uses an
explicit `return`.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/ConditionalExpressions", slice: "escapeHatch")

## Branches are type checked independently

A ternary unifies the types of its two sides. A conditional expression does not,
so branches that would each infer a different literal type need an annotation to
say what the result is.

```swift
let adjustment = if temperature > 85 { 0 } else { 1.5 }
// error: branches have mismatching types 'Int' and 'Double'
```

The same rule is why a `nil` branch needs one: nothing in the branches says which
optional type is meant.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/ConditionalExpressions", slice: "explicitType")

Conditional expressions nest inside each other and inside ternaries, and each
nested expression is type checked the same way.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/ConditionalExpressions", slice: "nested")

## Only a few positions accept one

A conditional expression is allowed as the source of an assignment, after
`return`, after `throw`, as a closure body, or as a property's value. Anywhere
else it is a statement again, and using it as one is an error:

```swift
print(if temperature > 85 { "hot" } else { "not hot" })
// error: 'if' may only be used as expression in return, throw, or as the
//        source of an assignment
```

That rules out an argument list and any larger expression, so
`"Temp: " + (if ... )` does not compile either.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/ConditionalExpressions", slice: "positions")

The `return` is optional in `adviceWithoutReturn` for the same reason it is
optional in any single-expression function body.

One position reads oddly: a throwing branch makes the expression throwing, but
`try` does not go in front of it. The error still has to be handled by an
enclosing `do`-`catch` or a throwing function.

```swift
let warning: String = try if temperature == 60 { "lukewarm" }
                          else { throw ReadingError.tooCold }
// warning: 'try' has no effect on 'if' expression
```

## Prefer a ternary for a two-way choice

For one condition and two values the ternary is shorter and reads in one line.
Nesting is where that reverses: a nested ternary puts each condition in the
middle of the line, while a chained `if` expression keeps each one at the front
of its own line.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/ConditionalExpressions", slice: "ternary")

A ternary branch can `try` a throwing call, but it cannot `throw`, because
`throw` is a statement and both sides of a ternary must be expressions.

```swift
input == 1 ? 1 : throw ReadingError.tooCold
// error: expected expression after '? ... :' in ternary expression
```

## Objective-C has no conditional expression

The ternary is the only conditional expression Objective-C has built in. Two
constructs get close.

An immediately invoked block is the direct analog of the Swift closure above,
and is plain Objective-C:

```objc
NSString *advice = ^NSString *{
    if (temperature > 85) { return @"Too hot"; }
    return @"Not too hot";
}();
```

A statement expression is a compound statement wrapped in `({ ... })`, where the
value of the last expression becomes the value of the whole thing. It is a GCC
extension that Clang supports:

```objc
NSString *advice = ({
    int adjusted = temperature - 2;
    NSString *result;
    if (adjusted > 85) {
        result = @"Too hot";
    } else {
        result = @"Not too hot";
    }
    result;
});
```

This is looser than a Swift conditional expression in both directions. It takes
as many statements as needed, but nothing checks that every path assigns
`result` — leave out the `else` and the value is `nil` rather than an error.
