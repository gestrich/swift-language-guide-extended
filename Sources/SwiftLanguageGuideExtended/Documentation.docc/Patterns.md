# Patterns

Match the shape of a value, and bind the parts of it that matter, in a case
label or a condition.

## Overview

A `case` label holds a pattern rather than a value. A pattern says what a value
has to look like to match, and it can name the parts it matched along the way.
That is what separates a `switch` from a chain of equality tests: a range, a
tuple shape, an enumeration case with its payload, and a dynamic type are all
patterns.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/Patterns", slice: "rangePattern")

Patterns are not confined to `switch`; the same syntax works in an `if`, a
`guard`, and a `for`-`in` loop. For the control-flow rules of the statement
itself — exhaustiveness, `fallthrough`, and `break` — see
<doc:SwitchStatements>.

## The kinds of pattern

| Pattern | Written as | Matches |
| --- | --- | --- |
| Expression | `case 1..<5:` | Any expression, tested with `~=` |
| Wildcard | `case _:` | Anything, binding nothing |
| Value binding | `case let count:` | Anything, binding it to a name |
| Tuple | `case (1, 0):` | Each element against its own pattern |
| Enumeration case | `case .north(let miles):` | One case of an enum, with a tuple pattern for its associated values |
| Optional | `case let name?:` | An optional holding a value, binding what it holds |
| Type casting | `case is Int:` or `case let text as String:` | The dynamic type; the `as` form also binds the cast value |

The tuple pattern is a container: each of its elements is itself a pattern, so
`case (let distance, 0)` combines a value binding with an expression pattern.

An optional pattern reads well in a loop that should skip the `nil` entries.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/Patterns", slice: "optionalPattern")

A type-casting pattern tests the dynamic type, and the `as` form gives the case
body a value already at that type.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/Patterns", slice: "typeCastPattern")

## An expression pattern matches through the pattern-match operator

An expression in a case label is not compared with `==`. It is passed to
`~=`, whose left operand is the pattern and whose right operand is the value.
Read it as "does this pattern contain this value". The operator is an ordinary
function and can be called directly.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/Patterns", slice: "tildeEqual")

The standard library supplies `~=` for ranges, and for any `Equatable` type by
falling back to `==`. So a custom type can be matched once it has the
conformance the pattern needs: `Equatable` for an equality case, `Comparable`
for a range.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/Patterns", slice: "customType")

## Value binding names what the pattern matched

Putting `let` in front of a name binds whatever that position matched, for the
body of the case. `var` binds a mutable copy.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/Patterns", slice: "valueBinding")

A binding that matches everything acts as a wildcard that also gives the value a
name, which is why `case let (x, y)` needs no `default`.

The `let` may also be written on each element instead of in front of the tuple.
Both forms bind the same things; Apple's examples use the outer form.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/Patterns", slice: "bindingForms")

## A where clause adds what the pattern cannot say

A pattern describes one value at a time. It cannot express a relationship
between two bound values, or any condition that needs a computation. A `where`
clause runs after the pattern matches and can use its bindings.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/Patterns", slice: "whereClause")

The exhaustiveness checker does not evaluate `where` clauses, so cases that
carry one never count toward covering the type. A switch built entirely from
`where` cases always needs a `default`, even when the conditions plainly cover
every value.

## A compound case lists several patterns

Commas in a case label separate alternative patterns, and the case matches if
any of them does. Every pattern in the list must bind the same names at the same
types, because the body is compiled once for all of them.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/Patterns", slice: "compoundCase")

Each pattern in the list may carry its own `where`.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/Patterns", slice: "compoundWhere")

## Patterns also work in if, guard, and for

Writing `case` after `if` or `guard` turns a pattern into a condition, and
writing it after `for` filters the sequence to the elements that match.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/Patterns", slice: "ifCase")

An `if case` is worth reaching for when the pattern does something an operator
cannot — a range, or a binding. When the test is plain equality,
`if origin == (0, 0)` says the same thing more directly.

The condition form is also more limited than a case label. It takes a single
pattern, so no comma-separated alternatives, and it takes no `where`; the comma
in a condition list already means something else.

```swift
if case let (x, y) = point where x == y { }
// error: expected ',' joining parts of a multi-clause condition
```

In a loop the filter happens before the body runs, which keeps the body free of
a leading `continue`.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/Patterns", slice: "forCase")

A `where` clause on a `for` loop needs no `case`, but it also cannot introduce a
pattern — it only filters on the element the loop already bound.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/Patterns", slice: "forWhere")
