# Swift Language Guide Extended

A guide to the Swift language, published as a DocC site:
**https://gestrich.github.io/swift-language-guide-extended/**

It covers Swift's syntax, the rules behind that syntax, and the behavior you
get at runtime, one feature at a time. An article states a rule, shows a short
example of it working, and marks the edges of the feature — the cases where it
does not apply and the mistakes it invites. It is written for someone who
already writes Swift and wants one concept explained properly.

The material expands on Apple's [Swift Language Guide][guide], covering the
same language in more depth.

[guide]: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/

## Layout

- `Sources/SwiftLanguageGuideExtended/Documentation.docc/` — the articles, one
  folder per chapter.
- `Snippets/` — the compiled home of every code example, embedded with
  `@Snippet`.
- `.github/workflows/docs.yml` — builds the DocC archive on every push to
  `main` and deploys it to GitHub Pages.
- `.agents/skills/` — skills describing the writing conventions for this
  project (`.claude/` is a symlink to it).
- `AGENTS.md` — instructions for AI agents working in this repo (`CLAUDE.md` is
  a symlink to it).

## Building the docs locally

One script builds and serves the site:

```
.agents/skills/building-docs/scripts/docs.sh serve
```

It compiles the snippets, builds `_site`, serves it on a free port in the
background, and prints the URL to open. `docs.sh stop` shuts the server down,
`docs.sh build` builds without serving, and `docs.sh --help` lists the rest.

The same script runs in CI, so a build that works locally works there.
`.agents/skills/building-docs/SKILL.md` explains the commands, why a deployed
build differs from a local one, and why `file://` cannot open either.
