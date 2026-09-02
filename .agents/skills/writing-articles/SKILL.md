---
name: writing-articles
description: Editorial conventions for the articles on this site — the shape of an article, the rhythm of a section, how code examples are written, and the prose rules. Use when writing, editing, or migrating any article under Documentation.docc.
---

# Writing Articles

These articles form an extended edition of Apple's Swift Language Guide,
written to replace the guide rather than summarize it. A reader arrives knowing
some Swift and wanting one concept explained properly. They read on a phone.
They are not told anything about how the site is produced or where its material
came from.

This skill covers what an article looks like and how it is written. DocC
mechanics — catalog layout, link syntax, what DocC silently mis-renders — are in
the `docc` skill. Read both before writing.

## The Shape of an Article

One article covers one concept. Every article has the same four parts, in this
order:

```markdown
# Checking API Availability

One sentence saying what the article covers.

## Overview

Two or three paragraphs and one small example: the whole idea, stated plainly.

## First idea

## Second idea
```

**Title.** Sentence case, no trailing punctuation, short enough not to be
truncated in the sidebar. Name the concept, not the chapter number.

**Abstract.** One sentence, no links. It appears under the title and in search
results, so it says what the reader will learn, not that the article exists.

**Overview.** The short version of the article. A reader who stops here should
have the correct mental model, just not the details. Give the problem the
feature solves, the one-paragraph answer, and the smallest example that shows
it. Do not list what the following sections will cover.

**Body.** One `##` section per concept, ordered so each section only relies on
what came before it. A concept is wider than a detail: `#available`'s syntax,
its wildcard, and its `#unavailable` inverse belong under one heading. Four to
six sections; more means details were given sections of their own, or the
article is two articles.

No summary section, and no closing list of related articles — the article ends
when the last idea is explained. Links to other articles go inline in the prose,
at the point where the reader would want them. A `## Topics` section inside an
article is DocC curation and would re-parent the sidebar; see the `docc` skill.

## The Rhythm of a Section

Every section follows the same three beats:

1. A heading naming the idea.
2. One to three sentences stating the rule.
3. A code block showing it.

Then stop, or add a single sentence drawing the consequence. Never open with a
code block; the reader should know what they are looking at before they look.
Never leave a code block unexplained, and never explain in prose what the code
already says line by line.

Headings are sentence case and carry no backticks or links, which DocC renders
literally. A heading names the concept the section covers — "The #available
condition" — rather than a claim the section proves. A sentence-shaped heading
is one detail wide, which is how an article reaches ten of them.

A section covering a concept runs the three beats once per detail it holds.

Three optional section types recur and are worth reaching for:

- **A comparison table** when three or more things differ along the same axes.
  Tables read better than three parallel paragraphs, and better than bullets.
- **"What it does not do"** — the boundaries of a feature. Most confusion about
  a Swift feature is about its edges, so this section earns its place often.
- **"Mistakes worth naming"** as a closing section. Each item is a bolded
  sentence naming the mistake, then one or two sentences on why it is wrong and
  what to use instead.

## Code Examples

Examples are the point of these notes. The guide's examples are not reused;
either a shorter example shows the same idea, or a longer one is needed to show
it properly.

Every example that compiles lives in a snippet file and is embedded with an
`@Snippet` directive, so that CI compiles it. An example that demonstrates a
compiler error cannot compile, so it stays as a fenced code block in the
article. The section below covers where the files go; the `docc` skill has the
mechanics and the three ways snippets bite.

- Fence every block as `swift`.
- Keep lines under 72 columns. Anything wider scrolls sideways on a phone.
- Self-contained and minimal. No app scaffolding, no imports that the point does
  not need, no types defined just to have a type.
- Real names — `count`, `name`, `temperature` — never `foo` or `bar`.
- Show a result as a trailing comment rather than as `print` output:

```swift
let count = names.count   // 3
```

- Quote a compiler diagnostic verbatim, on the line under the code that
  produces it, wrapping with the continuation indented to the message:

```swift
if #available(iOS 26) { }
// error: must handle potential future platforms with '*'
```

An error message quoted from a real build is the strongest evidence an article
can carry. Never invent one or paraphrase it from memory — compile the example
and copy what the compiler printed.

## Where Articles Live

Articles are grouped by chapter, the same way snippets are — one folder per
chapter, holding the chapter's own page and one file per article:

```
Sources/SwiftLanguageGuideExtended/Documentation.docc/
    SwiftLanguageGuideExtended.md
    ControlFlow/
        ControlFlow.md
        IfStatements.md
```

Pages that belong to no chapter, like the landing page, stay at the top level.

The folder is filing and nothing else. An article's URL is
`/documentation/swiftlanguageguideextended/<filename>` whatever folder holds
it, `<doc:IfStatements>` links to it without naming the folder, and the sidebar
comes from the `## Topics` sections. So a filename still has to be unique
across the whole catalog, and moving a file between folders is safe while
renaming it is not.

## Where Snippets Live

Snippets are grouped by chapter — one folder per chapter, one file per article:

```
Snippets/
    ControlFlow/
        IfStatements.swift
        SwitchStatements.swift
```

The folder takes its name from the chapter's article (`ControlFlow.md`), the
file from the article it serves (`IfStatements.md`), and each slice from the
example it holds. The `@Snippet` path mirrors the directory:

~~~markdown
@Snippet(path: "SwiftLanguageGuideExtended/Snippets/ControlFlow/IfStatements", slice: "basic")
~~~

A snippet file's name has to be unique across the whole package. SwiftPM builds
each file as a product named by its basename and ignores the folders it sits
in, so two files named `Basic.swift` in different chapters produce:

```
warning: ignoring duplicate product 'Basic' (snippet)
```

One of them is then dropped, and the `@Snippet` that referenced it renders
nothing. Naming each file after its article keeps the names unique for free,
because article names already are.

That constraint is why a chapter folder holds one file per article and not one
per section. Slices already divide an article's examples, and a file per
section would need a chapter prefix in every name to stay unique — which is the
flat layout again, with more files.

## Findings, Experiments, and Corrections

Material that goes beyond the guide is not labeled as such. State it as a fact
and put the evidence next to it — usually a code block with its output or its
error. The reader does not need to know which sentence came from Apple.

Two exceptions, both DocC callouts:

```markdown
> Experiment: Change the deployment target to iOS 26 and rebuild.
```

Use `> Experiment:` for something the reader should run themselves, and
`> Note:` where the guide says something that is incomplete or no longer true.
Write the correction neutrally — say what is the case and why — and do not
belabor that the guide is wrong.

Callouts are rare. Two in an article is a lot.

## Prose Rules

Aim for how good technical documentation reads. Say the fact in ordinary word
order.

Cut:

- Filler: "actually", "just", "very", "simply".
- Openers: "It is important to note that", "In this section we will".
- A sentence that repeats the one before it, or a paragraph that repeats the
  heading.
- A trailing "so that…" clause explaining something already clear.
- "in order to", which is "to".

Avoid constructions chosen for effect:

- Showy word choice: "under the hood", "spin up", "first-class citizen".
- Clefts and inversions that hold the point until the end of the sentence.
- Two clauses built in matching shape, so the pair sounds like a saying.
- The "X, not Y" and "not just X but Y" contrast.
- An image invented on top of a term that already exists. Say "the importing
  code", not "code on the other side" of a module boundary.

Keep:

- The real names for types, attributes, and language constructs. The reader is
  technical, so use the field's vocabulary.
- Qualifiers that are true, and the "because" behind a claim.
- An example that makes an abstract rule concrete.

Define a term by saying what it means, in the sentence where it first appears.
Do not defer the answer to a later paragraph.

Being short matters less than being complete. Use the fewest words that still
say the whole thing.

## An Annotated Section

~~~markdown
## The #available condition                    <- the concept, as the heading

The condition is a list of platform-and-version pairs, and it must end in
`*`. Each pair applies only to a build for that platform; the `*` covers
every platform not named and means "the deployment target".
                                               <- the rule, in three lines

```swift
if #available(iOS 26, macOS 26, *) { }

if #available(iOS 26) { }
// error: must handle potential future platforms with '*'
```
                                               <- the working form, then the
                                                  failure and its real error

So in an iOS build, `#available(macOS 99, *)` always takes the then-branch:
the macOS clause does not apply, and the `*` decides.
                                               <- one consequence, then the
                                                  next beat
~~~

## Do Not

- Open an article with what it will cover, or close one with what it covered.
- Write in the second person as a tutorial: "Let's take a look at", "you'll
  want to".
- Number the headings, or use one generic enough to fit any article — "Syntax",
  "Notes".
- Bullet-list a set of ideas that each need a paragraph. Bullets are for items
  that are genuinely parallel and genuinely short.
- Restate a code block in prose underneath it.
- Use emoji, bold for emphasis mid-sentence, or adjectives like "powerful",
  "elegant", "simply a matter of".
- Paste playground comment text into an article unchanged. Migration is also an
  editing pass: rough phrasing gets rewritten, and accidental ordering gets
  fixed.
- Add a comment inside a code block that repeats the prose above it.

## Filenames

The filename is the article's public URL, so it is settled once and not
changed. Use the concept in PascalCase with no chapter number —
`CheckingAPIAvailability.md`, not `5-ControlFlow-Availability.md`. Chapter
numbers change when Apple reorganizes the guide; concepts do not.
