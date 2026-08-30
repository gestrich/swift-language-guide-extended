# About These Notes

Why this site exists and how it is organized.

## Overview

The notes on this site began as a single Xcode playground, one page per chapter
of the Swift Language Guide, with commentary written as comments alongside
compiling Swift. That format made the notes hard to read and impossible to
link to, so they were moved here.

This article is a placeholder. It exists so that navigation, the sidebar, and
per-article URLs can be verified before any real content is migrated. It will be
replaced as the chapters move over.

### What Belongs Here

An article per chapter of the Swift Language Guide, plus articles for topics
that sit outside the guide's chapter list — ABI stability, library evolution,
type erasure, and similar material.

### Building Locally

From the package root:

```
swift package --allow-writing-to-directory ./_site \
  generate-documentation \
  --target SwiftLanguageGuideExtended \
  --disable-indexing \
  --transform-for-static-hosting \
  --hosting-base-path swift-language-guide-extended \
  --output-path ./_site
```
