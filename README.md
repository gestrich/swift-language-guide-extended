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

- `Sources/SwiftLanguageGuideExtended/Documentation.docc/` — the articles.
- `Snippets/` — the compiled home of every code example, embedded with
  `@Snippet`.
- `.github/workflows/docs.yml` — builds the DocC archive on every push to
  `main` and deploys it to GitHub Pages.
- `.agents/skills/` — skills describing the writing conventions for this
  project (`.claude/` is a symlink to it).
- `AGENTS.md` — instructions for AI agents working in this repo (`CLAUDE.md` is
  a symlink to it).

## Building the docs locally

```
swift package --allow-writing-to-directory ./_site \
  generate-documentation \
  --target SwiftLanguageGuideExtended \
  --disable-indexing \
  --transform-for-static-hosting \
  --output-path ./_site
```

Then serve `_site` over HTTP — opening the files directly with `file://` will
not work, because the rendered page loads its assets by absolute path:

```
python3 -m http.server 8000 --directory _site
```

Open `http://localhost:8000/documentation/swiftlanguageguideextended/`. Any free
port works; 8000 is only the default in this command.

The deployed site adds `--hosting-base-path swift-language-guide-extended`,
which prefixes every asset path with that name. A build made with the flag has
to be served from a parent directory containing a `swift-language-guide-extended`
directory (or a symlink to `_site` under that name) rather than from `_site`
itself, and its URLs carry the prefix:
`http://localhost:8000/swift-language-guide-extended/documentation/swiftlanguageguideextended/`.
Leave the flag off unless you are reproducing a deployment problem.

To preview without the static-hosting transform, `swift package preview-documentation
--target SwiftLanguageGuideExtended` runs a local server that rebuilds on save.
