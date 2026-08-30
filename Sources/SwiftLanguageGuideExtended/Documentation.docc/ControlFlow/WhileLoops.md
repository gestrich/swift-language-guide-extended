# While loops

Repeat a body until a condition fails, when the number of passes is not known
before the loop starts.

## Overview

`while` evaluates its condition before each pass, including the first, so the
body may never run at all.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/WhileLoops", slice: "whileLoop")

Reach for `while` when the loop ends on a condition rather than on a count. A
`for`-`in` loop over a range or a collection is clearer whenever the set of
values is known up front; see <doc:ForInLoops>. Either form can also be left early with `break` or
skipped ahead with `continue`; see <doc:ControlTransferStatements>.

## A repeat-while loop always runs the body once

The `repeat` form moves the test to the end, so the body runs before the
condition is ever evaluated. This example decrements once even though the
starting value already fails the test.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/WhileLoops", slice: "repeatWhile")

Use it only when the starting state is already known to be valid, since nothing
guards the first pass.

## Process the current element, then advance

A loop that moves an index through a collection has to choose whether to advance
the index before or after the work. Advancing first leaves the index at an
element the loop condition has not checked, so the body needs a second bounds
test.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/WhileLoops", slice: "advanceFirst")

Processing first removes that test. The `while` condition validates the index
immediately before the body reads it, so the subscript at the top of the loop is
always in bounds.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/WhileLoops", slice: "processFirst")

The `repeat` form has the same shape, and the same restriction as above: the
first index has to be valid before the loop starts, because nothing checks it.

@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/WhileLoops", slice: "repeatProcessFirst")
