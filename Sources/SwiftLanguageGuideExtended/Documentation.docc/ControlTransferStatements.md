# Control transfer statements

Change where execution goes next, with continue, break, and the labels that say
which statement they apply to.

## Overview

Swift has five statements that transfer control: `continue`, `break`,
`fallthrough`, `return`, and `throw`. The first two belong to loops and
switches, and each one applies to the innermost loop or switch that encloses it
unless a label says otherwise. `fallthrough` is part of `switch` and is covered
in <doc:SwitchStatements>.

## continue skips to the next pass of the innermost loop

The rest of the body is abandoned and the loop moves on to the next element. In
a `while` loop the condition is re-evaluated first, as it would be at the
closing brace.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlTransferStatements", slice: "continueBasic")

When the `continue` is the first thing in the body, a `where` clause on the loop
says the same thing with less code and puts the condition where a reader looks
for it.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlTransferStatements", slice: "continueVsWhere")

## break ends the innermost loop or switch

Execution resumes at the first statement after the loop, so an outer loop
containing it carries on with its next pass.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlTransferStatements", slice: "breakInnerLoop")

Inside a `switch`, `break` ends the switch and leaves any enclosing loop
running.

## A label names the statement to leave

Prefixing a loop or a switch with an identifier and a colon lets `break` and
`continue` name it. That reaches an outer loop from inside an inner one.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlTransferStatements", slice: "labeledLoops")

On a `repeat`-`while` loop the label goes in front of `repeat`.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlTransferStatements", slice: "repeatLabel")

A switch can carry a label too, which is how a case body ends the loop around it
rather than the switch it is in. `continue` has no meaning for a switch, so a
switch label accepts only `break`.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlTransferStatements", slice: "breakLoopFromSwitch")

## A label replaces a flag that exists only to escape a loop

The usual alternative to a label is a Boolean that the inner loop sets and the
outer loop tests. It works, but the test after the inner loop is easy to leave
out, and it does nothing else for the code.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlTransferStatements", slice: "flag")

The label says the same thing in one statement.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlTransferStatements", slice: "labelInsteadOfFlag")

## A label on an if or do block is legal and worth avoiding

An `if` or `do` block can be labeled, and `break` with that label skips the rest
of the block and resumes after it.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlTransferStatements", slice: "labeledIf")

Nothing at the `break` shows how much code it skips, and that amount changes
whenever the block is reordered or another conditional is nested inside it.
Wrapping the remaining lines in a condition, or moving the block into its own
function and using a `guard`, keeps the skipped range visible.

An unlabeled `break` cannot be used this way at all. Inside an `if` that sits in
a loop it leaves the loop, and outside a loop or switch it is an error:

```swift
if temperature > 85 {
    break
}
// error: unlabeled 'break' is only allowed inside a loop or switch, a
//        labeled break is required to exit an if or do
```
