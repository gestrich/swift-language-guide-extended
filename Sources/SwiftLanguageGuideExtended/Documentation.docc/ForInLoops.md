# For-in loops

Walk the elements of any sequence, with the loop variable bound fresh on every
pass.

## Overview

`for`-`in` takes anything conforming to `Sequence` and binds each element to a
name for the body of the loop. Arrays, ranges, dictionaries, and strings all
work the same way, because they are all sequences.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ForInLoops", slice: "basic")

Swift has no C-style `for` loop — the `for (var i = 0; i < len; i += 1)` form
was removed in Swift 3. Where that form counted with an index, a range or a
`stride` supplies the numbers.

## The loop variable is a new binding each pass

The name after `for` is a constant, so `let` is neither needed nor allowed.
Writing `var` makes it mutable inside the body, but the assignment is discarded
when the pass ends; the next pass binds the next element from the sequence.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ForInLoops", slice: "varBinding")

## A range supplies the numbers a C-style loop would count

A closed range `1...5` includes both ends. A half-open range `0..<3` stops
before its upper bound, which is the form that matches a count.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ForInLoops", slice: "numericRange")

Use `_` in place of the name when the body only needs the number of iterations.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ForInLoops", slice: "ignoreElement")

## stride steps by a fixed interval

`stride(from:to:by:)` counts up to but not including its end, matching a
half-open range.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ForInLoops", slice: "strideTo")

`stride(from:through:by:)` includes its end, matching a closed range — but only
when the end lands on a step. Nothing rounds up to reach it.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ForInLoops", slice: "strideThrough")

## Iterating a dictionary gives key-value tuples in no fixed order

A dictionary's element is a `(key: Key, value: Value)` tuple, so the loop can
decompose it into two names.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ForInLoops", slice: "dictionary")

Bind a single name instead and reach the parts through `key` and `value`.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ForInLoops", slice: "dictionaryTuple")

A dictionary is unordered, so the order these come out in is not guaranteed and
may differ between runs. Sort the keys when the order matters.

## enumerated() pairs each element with its offset

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ForInLoops", slice: "enumerated")

The first value is an offset counted from zero rather than an index. For an `Array`
the two coincide, but for a slice or a `String` they do not, so it cannot be
used to subscript the collection.

## A where clause filters iterations

A `where` clause on the loop skips any element that fails it. It reads better
than an `if` wrapping the whole body, and better than a `continue` on the first
line — see <doc:ControlTransferStatements>. To filter on the *shape* of an
element rather than a condition, the loop takes a pattern instead; see
<doc:Patterns>.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ForInLoops", slice: "whereClause")
