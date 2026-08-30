---
name: docc
description: DocC mechanics for this documentation-only Swift package — catalog layout, article shape, sidebar groups via Topics, link syntax, callouts, and the syntax rules DocC silently breaks on. Use when adding or editing anything under Documentation.docc, or when changing how the site is built or navigated.
---

# DocC

This package has no API surface. It is a DocC catalog carried by a Swift package
so that `swift-docc-plugin` can build it, and the target's single Swift file
exists only because SwiftPM requires one. Everything readers see is an article.

This skill covers DocC mechanics: where files go, what DocC will and will not
render, and how navigation is built. It does not cover how to write an article
for this project — voice, structure, and editorial conventions live in a
separate skill.

## Catalog Layout

```
Sources/SwiftLanguageGuideExtended/
  SwiftLanguageGuideExtended.swift      placeholder, not documentation
  Documentation.docc/
    SwiftLanguageGuideExtended.md       landing page
    <Article>.md                        one file per article
    <Group>/                            folder for a sidebar group
      <Group>.md                        parent page for that group
      <Article>.md
```

The landing page filename matches the target name, and its title is the module
in double backticks:

```markdown
# ``SwiftLanguageGuideExtended``

One sentence describing the site.

## Overview

What this is and who it is for.

## Topics

### Group Name

- <doc:ArticleName>
```

Article filenames become URLs, so they are the shareable address of the article.
Renaming a file breaks any link anyone has saved to it.

The landing page carries a `@Metadata` directive so the site title reads as
prose instead of as the target name:

```markdown
# ``SwiftLanguageGuideExtended``

@Metadata {
    @DisplayName("Swift Language Guide Extended")
}

One sentence describing the site.
```

The directive goes between the title and the abstract.

## Article Shape

The first heading is the sidebar title. Keep it short; it can be truncated.

The abstract is the text immediately after the title and before `## Overview`.

- Keep the abstract to one sentence.
- Put links in body text, not in the abstract.
- Do not put a horizontal rule between the abstract and `## Overview`. DocC may
  read it as an implicit Overview section and the page structure comes out wrong.

```markdown
# Article Title

One sentence describing what this article covers.

## Overview

Main content.

## Topics

### Related

- <doc:RelatedArticle>
```

## Sidebar Groups

The sidebar is built from `## Topics`, not from the directory tree. An article
that is not linked from some `## Topics` section is still published and still has
a URL, but nothing navigates to it, and the build reports it as unresolved
curation.

To create an expandable group:

1. Create a folder for the group, such as `NonChapterTopics/`.
2. Create a parent Markdown file with the same name, `NonChapterTopics.md`.
3. Give the parent file a `## Topics` section listing the children.
4. Link the parent itself from the landing page's `## Topics`.

Child articles live in the folder that matches their sidebar group. Ordering
inside a `###` group follows the order the links are written in, so the list is
the running order of the site — not alphabetical.

## Links

- Another article: `<doc:ArticleName>` — the filename without `.md`, not the
  title.
- A section in another article: `<doc:ArticleName#Section-Heading>`.
- A section in the same article: use the same `<doc:...#...>` form.
- Anchors are the heading text with spaces replaced by hyphens, so
  `## Value Types` becomes `#Value-Types`.
- Do not use Markdown anchors like `[Text](#section)`; DocC does not resolve
  them.
- Ordinary external links use normal Markdown: `[The Swift Programming
  Language](https://docs.swift.org/...)`.

## Syntax Rules That Break Silently

These produce a wrong page rather than an error, so they are worth memorizing.

- No links and no backtick-quoted inline code in `##` or `###` headings. DocC
  may render the markup literally.
- No line of prose starting with `@`. DocC parses it as a directive. This
  catches a paragraph that happens to begin with `@objc`, `@MainActor`, or a
  property wrapper — reword so the line starts with a word, or put it in a code
  block. Real directives such as `@Metadata` are the intended use of that
  syntax and are fine.
- No HTML. `<sup>` and `<sub>` in particular are not supported; use the Unicode
  superscript and subscript characters.
- Use real emoji characters, not shortcode names like `:white_check_mark:`.
- Image references need an explicit extension: `![Alt text](image-name.png)`.

## Callouts

```markdown
> Note: General information.
> Tip: Helpful suggestion.
> Important: Requirement or key information.
> Warning: Critical information.
> Experiment: Try this out.
```

The label must be one of those words followed by a colon. Anything else renders
as an ordinary block quote.

## Code Blocks

Fence with the language for highlighting:

````markdown
```swift
let x = 1
```
````

Fenced code in an article is inert text — DocC does not compile it. Keep code
blocks narrow; the site is read on a phone, and a long line forces horizontal
scrolling in the rendered block.

## Building

```
swift package --allow-writing-to-directory ./_site \
  generate-documentation \
  --target SwiftLanguageGuideExtended \
  --disable-indexing \
  --transform-for-static-hosting \
  --hosting-base-path swift-language-guide-extended \
  --output-path ./_site
```

`--hosting-base-path` must match the repository name, because the site is served
from `https://gestrich.github.io/swift-language-guide-extended/`. If it does not
match, every asset URL is wrong and the page renders blank.

The generated landing page lands at
`documentation/swiftlanguageguideextended/`, not at the site root. The workflow
writes an `index.html` redirect at the root to cover that.

For a local read-through, `swift package preview-documentation --target
SwiftLanguageGuideExtended` serves the catalog and rebuilds on save. To check
the real static output instead, serve `_site` over HTTP; `file://` will not work.

## Warnings Worth Reading

`generate-documentation` reports unresolved `<doc:` links and uncurated pages as
warnings, and the build still succeeds. A typo'd link therefore ships as plain
text. Read the warning output after every build that adds or renames an article.
