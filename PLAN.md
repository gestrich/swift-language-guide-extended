# Plan: Swift Language Guide Extended

A migration plan. It moves a long-running set of personal Swift notes out of an
Xcode playground and into a DocC catalog published as a static site on GitHub
Pages, and it builds the AI skills needed to keep writing those notes in a
consistent voice and structure.

This document is self-contained. An agent picking it up cold should be able to
execute it step by step without further background from Bill.

**Record decisions here as steps finish.** When a step is done, write down any
implementation decision that is not obvious from the resulting code — something
that was chosen between alternatives, a constraint discovered along the way, or
a workaround whose reason would otherwise be lost. Later steps are written
against assumptions this document makes, so a decision that changes those
assumptions has to be visible to whoever picks up the next step. Add it as an
"Implementation notes" section at the end of the step it came from. Skip
anything the code already states plainly.

**Publish after every change.** The site is the deliverable. When
a step — or any piece of work inside a step — changes the catalog, commit and
push to `main` so the Pages workflow rebuilds, then confirm the change is live
at `https://gestrich.github.io/swift-language-guide-extended/`. A local
`generate-documentation` run is a check, not a substitute: it does not exercise
the hosting base path, the root redirect, or how the page reads on a phone.

---

## Background

Bill has studied Apple's [Swift Language Guide][guide] for years and kept his own
notes on it. The notes are not a summary. They cover the same concepts and
information the guide covers, interpreted and expanded — small experiments that
validate or extend what the guide says, explanations restated in a form Bill
finds clearer, and material the guide leaves implicit. The goal has always been
that the notes *replace* the guide for him. Think of it as an extended edition
rather than a companion.

The notes deliberately do not preserve Apple's examples. Where Bill has an
example that shows the same idea more concisely, or one that needs to be more
expansive, his example wins. What must be preserved is the coverage: every
concept and piece of information the guide conveys should be present.

The notes currently live in one Xcode playground, one page per guide chapter, at
`/Users/bill/Developer/personal/apple-examples/swift-language-guide/swift-study-guide.playground`.
Commentary is written as `//` and `/* */` comments alongside compiling Swift.

[guide]: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/

## Why move off playgrounds

Four problems, all of them structural rather than cosmetic.

**Comments are a bad container for long-form writing.** A paragraph of
explanation becomes a wall of comment text with no headings, no lists, no
emphasis, no links. Markdown is the right format for this, and Markdown inside a
playground comment is worse than either — you read the syntax instead of the
rendered result, because Xcode playgrounds have no Markdown viewer for it.

**The notes are not reachable.** They are a reference, not an experiment, but
reading them requires a Mac, Xcode, and opening the project. Bill wants a URL:
open it on a phone, see the whole tree of chapters, and search it.

**The notes cannot be shared.** Bill wants to link someone to a specific article.
A playground page has no address.

**AI writes them badly.** Asking an AI to draft or edit a section produces
overly verbose prose, and edits get inserted literally without regard for how the
article flows or how these articles are structured. Every request takes several
rounds of correction because none of the conventions are written down anywhere
the AI can read. Skills — Markdown files that tell Claude Code or Codex how to
work in a project — are the fix, but they have to exist first.

## Target end state

- A public GitHub repository, `gestrich/swift-language-guide-extended`.
- A Swift package in that repo containing a DocC catalog.
- One DocC article per chapter of the Swift Language Guide, migrated from the
  playground pages, plus articles for the extra topics Bill has written that sit
  outside the guide's chapter list.
- A GitHub Actions workflow that builds the DocC archive on every push to `main`
  and deploys it to GitHub Pages, giving a live, searchable, linkable site at
  `https://gestrich.github.io/swift-language-guide-extended/`.
- Skills checked into the repo covering DocC mechanics and — separately — the
  article structure and writing conventions for this project, so that a first-try
  AI edit is usable.

## Decisions already made

- **GitHub Pages, not S3.** An earlier version of this plan used an S3 static
  site provisioned by Terraform with a GitHub Action uploading the built DocC.
  That was dropped. Pages is simpler, needs no AWS account or infrastructure
  code, and requires the repo to be public — which is fine.
- **Public repo.** Required by Pages on a free plan, and Bill wants to share
  links anyway.
- **One target to start.** The first iteration is a single library target with a
  single DocC catalog. Split it later only if there is a reason.
- **DocC, not a general static-site generator.** Bill wants Apple's
  documentation format specifically.

## Open questions to settle during the work

These are called out again in the step where they matter. They are listed here so
they are not lost.

1. **How does example code stay compiled?** The playground type-checked every
   snippet for free. Markdown code blocks in a DocC article are inert text — a
   typo or an API change will not fail the build. Options are in Step 3.
2. **What happens to the chapter stubs?** Ten of the playground pages are
   five-line placeholders with no content (see inventory in Step 4). Migrate them
   as empty articles so the table of contents is complete, or leave them out
   until written?
3. **Where do the non-chapter pages go?** Five pages are not Swift Language Guide
   chapters: ABI Stability, Library Evolution, Type Erasure,
   HashabilityEquality, and "Blogs - Fun With Swift Numbers". They likely want
   their own section rather than being interleaved with the chapters.

## Reference material

**Source notes (read-only for this project).**
`/Users/bill/Developer/personal/apple-examples/swift-language-guide/`
Contains the playground plus PDF exports of several Apple guide chapters that
Bill used as source of truth, and `Control_Flow_Playground_Review.md`, a gap
analysis of one chapter against its PDF.

> Warning: The PDFs are Apple's copyrighted material. Do not copy them into the
> new public repo.

**DocC skill to adapt.**
`/Users/bill/Developer/work/ios/.claude/skills/documentation/SKILL.md`
A single-file skill covering DocC catalog layout, article shape, sidebar groups
via `## Topics`, DocC link syntax, callouts, and a set of real DocC syntax
gotchas (no links or inline code in headings, no lines starting with `@`, no
horizontal rule between abstract and Overview, no HTML `<sup>`/`<sub>`). It is
written for ForeFlight and contains ForeFlight-specific conventions and API
comment guidance that do not apply here.

**Working DocC-on-Pages example.**
`https://github.com/gestrich/SwiftLinuxDemo` — Bill's own repo, already
publishing a DocC site to GitHub Pages. `.github/workflows/docs.yml` is the
model to copy. Two details in it matter and are easy to get wrong:

- It installs a toolchain with `swift-actions/setup-swift@v2` even though
  `ubuntu-24.04` already ships Swift, because the Ubuntu-supplied toolchain omits
  the swift-docc render artifacts (CSS and JS). Building against it produces HTML
  that 404s on `/css/...` and `/js/...` and renders as a blank page.
- It writes an `index.html` redirect at the site root, because DocC's output puts
  the landing page at `documentation/<lowercased-target-name>/`, not at `/`.

Its `Package.swift` shows the `swift-docc-plugin` dependency that provides
`swift package generate-documentation`.

---

## Steps

Work one step at a time. Do not start the next step until the current one meets
its completion criteria.

## Step 1 — Scaffold the package, catalog, and Pages deployment end to end

- [x] Scaffold: Swift package + DocC catalog + GitHub Actions → Pages, proven live

This is a tracer. The point is to prove the whole chain works — commit, build,
deploy, load in a browser — before any real content exists. No notes get migrated
in this step.

**What to build**

1. `git init` in `/Users/bill/Developer/personal/swift-language-guide-extended`
   (currently an empty, non-git directory). Default branch `main`.
2. A Swift package named `SwiftLanguageGuideExtended`, using
   `swift-tools-version: 6.2`, with one library target of the same name and a
   dependency on `https://github.com/apple/swift-docc-plugin` from `1.4.0`.
   Model the manifest on SwiftLinuxDemo's, minus its platform-exclusive
   machinery, which is irrelevant here.
3. `Sources/SwiftLanguageGuideExtended/Documentation.docc/` containing:
   - `SwiftLanguageGuideExtended.md`, the landing page, with a title, a
     one-sentence abstract, an `## Overview` explaining what this site is, and a
     `## Topics` section.
   - One placeholder article, linked from `## Topics`, so the sidebar and
     navigation are exercised.
4. `.gitignore` covering `.build/`, `.swiftpm/`, `.DS_Store`, `_site/`.
5. `README.md` at the repo root: what this is, a link to the published site, and
   how to build the docs locally.
6. `.github/workflows/docs.yml`, adapted from SwiftLinuxDemo's. Change the
   target name and set `--hosting-base-path swift-language-guide-extended` to
   match the repo name — a project Pages site is served from
   `https://gestrich.github.io/<repo>/`, and the base path must match or every
   asset link breaks. Keep the `setup-swift` step and the root `index.html`
   redirect for the reasons given in Reference material.
7. Copy `/Users/bill/Developer/work/ios/.claude/skills/documentation/SKILL.md`
   into `~/.claude/skills/docc-bill/SKILL.md` and adapt it: strip the ForeFlight
   framing and keep the catalog layout, article shape, `## Topics` sidebar
   grouping, link syntax, callouts, and the syntax gotchas. The skill is
   personal, not repo-local, so it must stay general enough to apply to any
   Swift package — this project's specifics belong in it only as examples.
8. Verify the build locally before pushing anything:
   `swift package --allow-writing-to-directory ./_site generate-documentation --target SwiftLanguageGuideExtended --disable-indexing --transform-for-static-hosting --hosting-base-path swift-language-guide-extended --output-path ./_site`
9. Create the remote: `gh repo create gestrich/swift-language-guide-extended --public`.
   Push `main`.
10. Enable Pages with **GitHub Actions** as the source (not "deploy from a
    branch"). `gh api -X POST repos/gestrich/swift-language-guide-extended/pages`
    with `build_type=workflow`, or via the repo's Settings → Pages.

**Completion criteria**

- `https://gestrich.github.io/swift-language-guide-extended/` loads in a browser
  and redirects to the DocC landing page.
- The landing page renders with styling — not a blank or unstyled page, which is
  the symptom of the missing render-artifacts problem.
- The placeholder article is reachable from the sidebar and has its own URL.
- The site is usable on a phone.
- The workflow runs green on push to `main`.

**Implementation notes**

- *Article filenames are the public URLs.* DocC derives the address from the
  filename, so `About.md` is served at
  `documentation/swiftlanguageguideextended/about/`. Renaming a file later
  breaks any link someone saved. Settle a filename convention for the chapters
  before Step 4 migrates 34 of them — in particular whether the guide's chapter
  numbers appear in the name, since renumbering would break URLs.
- *The landing page needs a display name.* DocC titles the module page with the
  target name, which reads as `SwiftLanguageGuideExtended`. The page carries a
  `@Metadata { @DisplayName("Swift Language Guide Extended") }` directive to fix
  that.
- *The target's Swift file is deliberately internal.* SwiftPM requires at least
  one source file, but any `public` symbol would show up in the rendered
  navigation next to the articles. If Step 3 chooses the "code in the library
  target" option for compiled examples, this changes — that option makes the
  symbols the point.
- *CI installs a toolchain and must update apt first.* The `setup-swift` step is
  there for the DocC render artifacts, as the plan already notes. Separately,
  the runner image ships a package index older than the Ubuntu mirrors, so
  `apt-get install` 404s unless `apt-get update` runs first. The libcurl and
  libxml2 installs were inherited from SwiftLinuxDemo and may not be needed by a
  package with no dependencies; they were left in rather than tested away.
- *Pushing requires the right identity.* `gh` on this machine has two accounts
  and `bill_jepp` is normally active, so `gh auth switch --user gestrich` comes
  first. The `gestrich` account blocks pushes that would publish a private
  email (`GH007`), so the repo's local git config commits as
  `3207996+gestrich@users.noreply.github.com`.
- *`--disable-indexing` was kept* from SwiftLinuxDemo without evaluating it.
  Step 5 already plans to revisit whether removing it improves search.
- *The DocC skill lives at `~/.claude/skills/docc-bill/SKILL.md`*, not in this
  repo. It started as a repo-local skill named `docc`, which collided with a
  personal skill of the same name; the personal one won the name and was marked
  `user-invocable: false`, so no slash command was registered and the repo-local
  skill never appeared in the listing. The two were merged into one personal
  skill instead, which also drops the stale `add-docc.py`, `/add-docc`,
  `module-structure`, and `dev-app` references the personal one carried — none
  of those exist. Only `writing-articles` stays repo-local, because its
  editorial conventions are specific to this site.

## Step 2 — Write the authoring skill: article structure and writing voice

- [x] Author the skill that defines what a good article in this project looks like

This is the step that fixes the "AI writes them badly" problem. Step 1's DocC
skill covers mechanics — syntax, catalog layout, what DocC will and will not
render. This step covers editorial conventions: what an article in *this* project
is shaped like and how it is written.

Do this before migrating content, so the migration produces articles in the right
shape the first time rather than needing a second pass.

**Inputs to draw on**

- The existing playground pages, particularly the fully developed ones — Control
  Flow (1405 lines), Strings (1142), Basics (1011), Basic Operators (485),
  Collections (442). These show Bill's actual voice and how he organizes material
  today, including his `/*======== Section ========*/` banner convention, which
  becomes a Markdown heading.
- `Control_Flow_Playground_Review.md` in the playground directory, which shows
  how Bill audits a chapter against Apple's source document for coverage gaps.
- Bill's global writing rules in `/Users/bill/.claude/CLAUDE.md`. They are
  detailed and directly relevant — say the fact in ordinary word order, no showy
  word choice, no clefts, no "X, not Y" contrasts, no invented imagery on top of
  established terms, cut filler, keep real API names and the "because" behind a
  claim, prefer complete over short. These rules should be referenced or restated
  in the skill so an agent working in this repo picks them up without loading the
  global file.

**Interview Bill before writing.** Do not infer the conventions entirely from the
existing pages — they are years of accreted style, not a deliberate standard.
Ask about at least:

- The standard shape of an article. Title, abstract, overview, then what? Does
  each concept get a heading, or do related concepts group?
- The relationship to Apple's chapter. Same order as the guide, or reorganized?
- How much of the guide's coverage is mandatory versus optional.
- When commentary is prose above a code block versus a comment inside it.
- How to mark things that are Bill's own findings or experiments rather than
  restatements of the guide.
- How to handle "the guide says X, but actually Y" corrections.
- Article length — is a 1400-line chapter one article or several?
- Whether articles cross-link to each other and to Apple's guide.

**Deliverable**

`.claude/skills/<name>/SKILL.md` in the repo — name it for what it does, e.g.
`writing-articles`. It must be concrete enough that an agent asked to "add a
section on `defer` to the Control Flow article" produces something Bill accepts
with light editing. Include a short annotated example of a good article section,
and an explicit list of things not to do, drawn from the failure modes Bill has
hit.

**Completion criteria**

- The skill exists and is committed.
- Bill has read it and confirms it describes what he wants.
- It has been exercised at least once: ask an AI to draft one section using only
  the skill, and confirm the output is close enough to be worth editing rather
  than rewriting.

**Implementation notes**

- *The interview was skipped by Bill's instruction.* Rather than eliciting the
  conventions, they were designed: concise, consistent, and aimed at a reader on
  a phone. The playground's accreted style was deliberately not treated as the
  standard. Expect to revise the skill once Bill has seen it applied to real
  chapters — Step 3 already plans for that.
- *The skill landed at `.claude/skills/writing-articles/SKILL.md`.* It splits
  cleanly from the `docc` skill, which covers only what DocC will and will not
  render. Each skill points at the other.
- *The conventions in short.* One concept per article. Title, one-sentence
  abstract, `## Overview` carrying the whole idea, then one `##` section per
  idea with a hard cap of about six. Every section runs heading, rule in one to
  three sentences, code block, optional consequence — never a code block first.
  Headings are sentence-case claims, not labels. Code is under 72 columns for
  phone reading, uses real names, shows results as trailing comments, and quotes
  compiler diagnostics verbatim from a real build.
- *Bill's own findings are not labeled.* They are stated as fact with the
  evidence beside them — usually the compiler's actual output. Only two callouts
  are sanctioned: `> Experiment:` for something to run, and `> Note:` for a
  correction where the guide is incomplete or out of date.
- *Bill's global writing rules from `~/.claude/CLAUDE.md` were restated in the
  skill*, not referenced, so an agent working in this repo picks them up without
  loading a file outside it. They will drift apart eventually; the repo copy is
  authoritative for this project.
- *Filename convention settled* — the open question flagged in Step 1. Concept
  name in PascalCase, no chapter number: `CheckingAPIAvailability.md`. Chapter
  numbers change when Apple reorganizes the guide, and the filename is the
  permanent URL.
- *The skill was exercised on one article.* `CheckingAPIAvailability.md` was
  written to the conventions, ported from the DocC catalog in
  `~/Downloads/ControlFlowExperiment`, and curated under a `### Control Flow`
  group on the landing page. It is a section of the Control Flow chapter, so it
  is the right size to prove the shape without pre-empting the Step 3 pilot.

## Step 3 — Migrate one chapter as a pilot, and settle the compiled-code question

- [ ] Pilot-migrate a single chapter end to end, then review before scaling up

Migrating 34 pages with unproven conventions risks 34 pages of rework. Do one
first. Control Flow is the best candidate — it is the largest, the most recently
worked on, and it already has a written gap analysis against Apple's PDF.

**Settle how example code stays compiled.** The playground type-checked
everything. Markdown code blocks in a DocC article do not compile, so nothing
catches a typo or a language change. This matters because the notes' value comes
partly from the code being known-good. Resolve it here, in the pilot, before it
is baked into 34 articles. Options, roughly in order of preference:

- **SwiftPM snippets.** Put example code in a top-level `Snippets/` directory.
  `swift build` compiles snippets, and `swift-docc-plugin` can embed them in
  articles with the `@Snippet` directive. Keeps compilation and keeps the code in
  the rendered article.
- **Code in the library target**, referenced from articles as DocC symbol links.
  Compiles, but forces every example to be a declaration, which fits some
  material poorly.
- **Fenced code blocks with a test target** that duplicates the examples. Two
  copies to keep in sync; weakest option.
- **Plain fenced code blocks, uncompiled.** Simplest, and loses the guarantee.

Prototype the chosen approach in the pilot and confirm it renders and builds in
CI. If snippets work, they are the answer.

**Then migrate the chapter.**

1. Read `Pages/5-Control Flow.xcplaygroundpage/Contents.swift` in full.
2. Convert it to a DocC article following the Step 2 skill: comments become prose
   with real headings, `/*==== banners ====*/` become `##` headings, code becomes
   snippets or code blocks per the decision above.
3. Do not mechanically transcribe. Where the playground's phrasing is rough or
   the organization is accidental, improve it — the migration is also an editing
   pass.
4. Cross-check against `Control_Flow_Documentation.pdf` and the existing
   `Control_Flow_Playground_Review.md`, which already lists known gaps in this
   chapter (`if` and `switch` expressions, `defer`, `if case` / `for case`
   patterns, `#unavailable`, and several smaller notes). Decide with Bill whether
   to close those gaps during migration or file them as follow-up work.
5. Link the article from the landing page's `## Topics`.
6. Push and confirm it renders correctly on the live site.

**Completion criteria**

- The Control Flow article is live and reads well on a phone.
- The compiled-code approach is decided, implemented, and verified in CI.
- Bill has reviewed the result and either approved the conventions or sent back
  changes, which are folded into the Step 2 skill before Step 4 begins.

**Implementation notes**

- *Snippets won, and the plan's ranking held up.* Compilable examples live in
  `Snippets/<Chapter>/<Article>.swift`, one file per article, cut into named
  regions with `// snippet.<name>` / `// snippet.end` markers and embedded with
  `@Snippet(path:slice:)`. Named slices are what makes this workable: an article
  has ten or more examples, and without them a snippet would have to be a whole
  file per example.
- *Snippet folders group by chapter, but do not namespace.* Subdirectories under
  `Snippets/` work — the `@Snippet` path mirrors them, so
  `Snippets/ControlFlow/IfStatements.swift` is referenced as
  `SwiftLanguageGuideExtended/Snippets/ControlFlow/IfStatements`. SwiftPM still
  names each snippet product by the file's basename alone, so basenames must be
  unique across the package; a duplicate is dropped with only
  `warning: ignoring duplicate product '<name>' (snippet)`, and the `@Snippet`
  referencing it renders nothing. Naming each file after its article keeps them
  unique, and is why a chapter folder holds one file per article rather than one
  per section.
- *Articles are grouped in a folder per chapter too.* The catalog mirrors
  `Snippets/`: `Documentation.docc/<Chapter>/<Article>.md`, with the chapter's
  own page in the folder as `<Chapter>/<Chapter>.md`. The folder is filing only.
  Article URLs stay `/documentation/swiftlanguageguideextended/<filename>`
  however deep the file sits, `<doc:ArticleName>` resolves without the folder in
  the path, and the sidebar comes from the `## Topics` sections. Filenames are
  therefore still the permanent URLs, and still have to be unique across the
  whole catalog.
- *The docs build does not compile snippets.* `generate-documentation` runs
  `snippet-extract`, which reads the file as text. A snippet with a type error
  renders correctly and the docs build succeeds. Only `swift build` compiles
  them, so the workflow runs it as its own step ahead of the docs build. This
  was verified by breaking a snippet on purpose: the docs build stayed green.
- *Error demonstrations stay as fenced code blocks.* A large share of the
  examples in this chapter exist to show a compiler diagnostic, and those cannot
  be snippets by definition. The split is the rule now: if it compiles it is a
  snippet, if it is an error it is a fenced block with the message quoted under
  it. Every diagnostic in the eleven articles was produced by an actual
  `swiftc` run rather than recalled.
- *Two snippet constraints to plan around.* All slices in a file share one
  top-level scope, so every name in the file must be unique. And a literal input
  gets constant-folded, so `let hour = 6` followed by a `switch` over it emits
  `warning: will never be executed` on the unreachable cases — iterating a small
  array of inputs, or taking the value as a function parameter, avoids that and
  usually makes the example better anyway.
- *The chapter became eleven articles, not one.* At 1405 lines the playground
  page is a chapter, and the Step 2 skill caps an article at one concept and
  about six sections. The split, in guide order: `ForInLoops`, `WhileLoops`,
  `IfStatements`, `SwitchStatements`, `ConditionalExpressions`, `Patterns`,
  `ControlTransferStatements`, `EarlyExit`, `DeferredActions`,
  `CheckingAPIAvailability` (already written in Step 2), and
  `ConditionalCompilation`. Expect the same for Strings and The Basics in
  Step 4; the inventory's line counts are counts of chapters, not of articles.
- *A per-article `## Topics` section is wrong here.* DocC treats `## Topics` as
  curation, so a "related articles" list at the bottom of an article makes that
  article the parent of everything it links, producing
  `warning: Organizing 'A' under 'B' forms a cycle` and a nested sidebar. Every
  article is curated once, from the landing page; cross-links go inline in the
  prose. The Step 2 skill said to close with `## Topics` and has been corrected.
- *Backticks in headings render literally,* as the `docc` skill already warned.
  DocC emits the heading text with the backtick characters in it. Headings that
  needed to name an API say it bare: "stride steps by a fixed interval".
- *The gap analysis was already closed.* `Control_Flow_Playground_Review.md`
  predates the playground's current state; `if`/`switch` expressions, the
  Patterns section, and Deferred Actions had all been written since. The two
  items still open were folded in during migration: that overlapping cases are
  allowed and the first match wins, and that `fallthrough` enters the next case
  body without testing its pattern or its `where`.
- *One finding came out of the migration.* The playground says `assert` cannot
  satisfy a `guard` body. `assert(false, "…")` does satisfy it in a debug build,
  because the optimizer inlines the literal-condition call to something that
  does not return — and stops satisfying it under `-O`, where assertions are
  removed. So the code compiles in Debug and fails to compile in Release. It is
  in `EarlyExit`, with both diagnostics.
- *Deliberate cuts from the playground page.* The parenthesis trivia around
  bindings (`let (x) = 15`, `case ((let (x))):`) and the "switch condition
  evaluates to a constant" warning, which no longer reproduces under `swiftc`.
  The Objective-C statement-expression contrast was kept, in
  `ConditionalExpressions`, because it is Bill's own material and it bears
  directly on the feature being explained.

## Step 4 — Migrate the remaining pages

- [ ] Migrate the rest of the playground pages, one at a time

Work through the inventory below. One page per pass. After each, push and check
the rendered result. Feed anything learned back into the Step 2 skill rather than
handling it ad hoc.

**Inventory** — 34 playground pages. Line counts are of `Contents.swift` and are
a rough proxy for how much work each carries.

*Substantial chapters:* 5-Control Flow (1405, done in Step 3), 3-Strings (1142),
1-Basics (1011), 2-Basic Operators (485), 4-Collections (442), 24-Generics (303),
7-Closures (289), 10-Properties (249), 6-Functions (208), 18-Concurrency (206),
8-Enumerations (164), 23-Protocols (120), 25-Opaque Types (101),
9-Structures_Classes (87), 11-Methods (85), 12-Subscripts (72),
13-Inheritance (67), 14-Initialization (55).

*Non-chapter topics:* Library Evolution (373), HashabilityEquality (338),
Type Erasure (293), Blogs - Fun With Swift Numbers (265), ABI Stability (114).
These are not Swift Language Guide chapters. Decide with Bill where they live —
most likely a separate `## Topics` group alongside the chapters.

*Empty stubs (5 lines each, no content):* 15-Deinitialization,
16-Optional Chaining, 17-Error Handling, 19-Macros, 20-Type Casting,
21-Nested Types, 22-Extensions, 26-Automatic Reference Counting,
27-Memory Safety, 28-Access Control, 29-Advanced Operators. Nothing to migrate.
Decide with Bill whether to create placeholder articles so the table of contents
mirrors the full guide, or omit them until they are written.

**Per-page procedure**

Follow Step 3's migration procedure. Where Bill has a PDF export of the matching
Apple chapter (The Basics, Strings and Characters, Collection Types, Control
Flow, A Swift Tour), use it to check coverage the way
`Control_Flow_Playground_Review.md` does, and record gaps rather than silently
leaving them.

**Completion criteria**

- Every page with content has a corresponding live article.
- The landing page's `## Topics` lists everything, grouped sensibly.
- Coverage gaps found along the way are recorded somewhere durable — a TODO file
  in the repo, or issues on the GitHub repo.

## Step 5 — Finish the site

- [ ] Navigation, cross-links, search, and a final read-through on a phone

With all content in place, treat the site as a product rather than a pile of
articles.

- Review the sidebar structure. Chapters in guide order; non-chapter topics
  grouped separately.
- Add cross-links between articles where one concept depends on another. DocC
  uses `<doc:ArticleName>` and `<doc:ArticleName#Section-Heading>`.
- Confirm DocC's built-in search finds what it should. Note that the workflow
  currently passes `--disable-indexing`, copied from SwiftLinuxDemo; check
  whether removing it improves search on the static site, and remove it if so.
- Read the whole site on a phone. Fix anything that reads badly at that width —
  wide code blocks and wide tables are the usual offenders.
- Update the README with the live URL and a short description.
- Retire or archive the playground: add a note in the old project pointing at the
  new site, so it is obvious which one is current.

**Completion criteria**

- Bill can find any concept from his phone in a few taps or one search.
- Every article has a shareable URL.
- The old playground clearly points at the new home.
