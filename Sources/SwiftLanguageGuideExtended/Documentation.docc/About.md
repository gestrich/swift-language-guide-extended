# About this guide

What this guide covers, who it is for, and how to read it.

## Overview

This guide covers the Swift language: its syntax, the rules behind that syntax,
and the behavior you get at runtime. It goes feature by feature, and an article
is finished when you can use its feature correctly without looking anything
else up.

The material expands on Apple's
[Swift Language Guide](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/).
Where that guide states a rule, this one shows the experiment behind it, the
cases it does not cover, and the errors the compiler raises when you get it
wrong.

## Who it is for

You have written some Swift and want one concept explained properly. This is
not an introduction to programming, and it does not teach the standard library
or any framework — it is about the language itself.

## How it is organized

One article per concept, grouped into chapters in the sidebar. Chapters follow
the language as Apple's guide divides it, with additional articles on topics
that sit outside that list — ABI stability, library evolution, type erasure,
and similar material.

Articles stand on their own and can be read in any order. Where one concept
depends on another, the prose links to it at the point it comes up.

## Code examples

Examples are short, self-contained, and compiled as part of this site, so the
code on the page is code the compiler accepted. When an example exists to show
a compiler error, the diagnostic appears verbatim beneath the line that
produces it.
