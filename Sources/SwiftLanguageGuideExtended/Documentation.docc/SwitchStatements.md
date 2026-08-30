# Switch statements

Match one value against a list of patterns and run the body of the first one
that matches.

## Overview

A `switch` takes a value and compares it against the pattern in each case label
in order. The body of the first matching case runs, and then the switch ends —
there is no implicit fall-through from one case to the next.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/SwitchStatements", slice: "basic")

A case label holds a *pattern* rather than a value, which is what makes
`switch` more than a chain of equality tests. The kinds of pattern are in
<doc:Patterns>.

## Every case needs at least one statement

A case cannot be empty; the compiler will not let one case run into the next by
accident. When a case exists only to say "matched, and there is nothing to do",
`break` is the statement to write.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/SwitchStatements", slice: "emptyCase")

## A switch must be exhaustive

Every possible value of the subject has to be matched by some case, or the
compiler rejects the switch:

```swift
switch reading {
case Int.min...Int.max:
    print("Every Int lands here")
}
// error: switch must be exhaustive
// note: add a default clause
```

The exhaustiveness check reasons about enum cases and tuples of them. It does
not reason about numeric ranges, so a set of cases that provably covers every
`Int` still needs a `default`.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/SwitchStatements", slice: "rangeNeedsDefault")

On an enum, that makes `default` worth avoiding. Listing the cases means adding
a case to the enum turns every switch over it into a compile error, which is a
list of the places that need attention. A `default` absorbs the new case
silently.

## The first matching case wins

Cases may overlap. They are tested top to bottom, and matching stops at the
first one, so a more specific case has to come before a more general one.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/SwitchStatements", slice: "firstMatchWins")

## fallthrough enters the next case body without testing it

`fallthrough` transfers control to the body of the following case
unconditionally. It does not evaluate that case's pattern, and it does not
evaluate its `where` clause either — a case that could never match on its own
still runs.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/SwitchStatements", slice: "fallthrough")

Because the pattern is skipped, the case fallen into cannot bind anything; there
is nothing to bind from:

```swift
switch point {
case (0, 0):
    print("origin")
    fallthrough
case let (x, y):
    print(x, y)
}
// error: 'fallthrough' from a case which doesn't bind variable 'x'
```

`fallthrough` also imposes an order on the cases: reordering them, or inserting
one between the pair, changes what runs. A compound case such as
`case .warning, .failure:` says the same thing without that coupling, and is the
better choice whenever the two bodies are identical.

## break in a switch ends only the switch

Inside a switch, `break` leaves the switch and execution continues after it. A
loop containing that switch keeps going.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/SwitchStatements", slice: "breakInSwitch")

To break out of the loop from inside the switch, label the loop and name it. See
<doc:ControlTransferStatements>.
