# Agent Instructions

An extended edition of Apple's Swift Language Guide, published as a DocC site.
See [README.md](README.md) for what the site is and how to build it locally.

The site is written for readers learning the language. Nothing in the published
articles refers to the project itself — how it is produced, that it started as
private notes, or that chapters are still being migrated.

## Where things are

- `Sources/SwiftLanguageGuideExtended/Documentation.docc/` — the articles. One
  file per concept, in a folder per chapter that also holds the chapter's own
  page (`ControlFlow/ControlFlow.md`). `SwiftLanguageGuideExtended.md` is the
  landing page. Folders only organize the files: the sidebar comes from the
  `## Topics` sections, and every article's URL is
  `/documentation/swiftlanguageguideextended/<filename>` whatever folder it is
  in.
- `Snippets/` — the compiled home of every code example, one folder per chapter
  and one file per article. DocC pulls them in with `@Snippet`; only
  `swift build` type checks them.
- `Reference/swift-book/` — Apple's book itself, as a git submodule of
  [apple/swift-book](https://github.com/apple/swift-book). Reference material
  only; nothing in the package builds it. See "The original book" below.
- `.agents/skills/` — project skills. `.claude/` is a symlink to `.agents/`.
- `PLAN.md` — the migration plan and its record of decisions.
- `.github/workflows/docs.yml` — builds and deploys to GitHub Pages on every
  push to `main`.

## Skills to read first

- `writing-articles` (in `.agents/skills/`) — article shape, section rhythm,
  code example style, prose rules. Read before writing or editing any article.
- `building-docs` (in `.agents/skills/`) — the script that builds, serves, and
  deploys the site. Read before running any documentation build.
- `docc-bill` (personal skill set, not in this repo) — DocC mechanics: catalog
  layout, link syntax, Topics groups, snippets, the syntax DocC silently breaks
  on.

## The original book

`Reference/swift-book/` is a git submodule pinned to a commit of
apple/swift-book, the repository docs.swift.org/swift-book is built from. Read
a chapter from disk rather than fetching the page from the web — it is the same
text, in DocC markdown, and it can be searched and diffed.

- Chapters live under `Reference/swift-book/TSPL.docc/`, in `GuidedTour/`,
  `LanguageGuide/`, `ReferenceManual/`, and `RevisionHistory/`. The file names
  match the chapter titles: `LanguageGuide/ControlFlow.md`.
- A fresh clone has the folder empty until `git submodule update --init`.
  Cloning with `--recurse-submodules` does it in one step.
- To move to a newer commit of the book, run `git submodule update --remote
  Reference/swift-book` and commit the changed pointer.
- `SummaryOfTheGrammar` has no source file. The published page is generated
  from the grammar directives in the other chapters by `bin/generate-grammar`.
- The Pages workflow does not check out submodules, so the deployed site never
  depends on it.

## Working conventions

- Build and serve the site only through `building-docs`. Its script compiles
  the snippets first, which is the only thing that type checks them — the docs
  build extracts them textually and will happily ship a broken example.
- Publish after every change that touches the catalog: commit and push to
  `main`, then confirm it is live at
  https://gestrich.github.io/swift-language-guide-extended/.
- Record non-obvious decisions in `PLAN.md` under the step they came from.
