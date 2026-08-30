# Agent Instructions

Personal notes on Apple's Swift Language Guide, published as a DocC site. See
[README.md](README.md) for what the notes are and how to build the site locally.

## Where things are

- `Sources/SwiftLanguageGuideExtended/Documentation.docc/` — the articles. One
  file per concept; `SwiftLanguageGuideExtended.md` is the landing page and its
  `## Topics` section controls the sidebar.
- `Snippets/` — the compiled home of every code example. One file per article.
  DocC pulls them in with `@Snippet`; only `swift build` type checks them.
- `.agents/skills/` — project skills. `.claude/` is a symlink to `.agents/`.
- `PLAN.md` — the migration plan and its record of decisions.
- `.github/workflows/docs.yml` — builds and deploys to GitHub Pages on every
  push to `main`.

## Skills to read first

- `writing-articles` (in `.agents/skills/`) — article shape, section rhythm,
  code example style, prose rules. Read before writing or editing any article.
- `docc-bill` (personal skill set, not in this repo) — DocC mechanics: catalog
  layout, link syntax, Topics groups, snippets, the syntax DocC silently breaks
  on.

## Working conventions

- Run `swift build` after touching anything under `Snippets/` — the docs build
  extracts snippets textually and will happily ship a broken example.
- Publish after every change that touches the catalog: commit and push to
  `main`, then confirm it is live at
  https://gestrich.github.io/swift-language-guide-extended/.
- Record non-obvious decisions in `PLAN.md` under the step they came from.
