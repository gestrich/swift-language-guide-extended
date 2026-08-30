# Swift Language Guide Extended

Personal notes on Apple's [Swift Language Guide][guide], published as a DocC
site: **https://gestrich.github.io/swift-language-guide-extended/**

[guide]: https://docs.swift.org/swift-book/documentation/the-swift-programming-language/

The notes are not a summary. They cover the same concepts and information the
guide covers, interpreted and expanded — experiments that validate or extend
what the guide says, explanations restated in a clearer form, and material the
guide leaves implicit. The goal is that they replace the guide, so the coverage
matters more than the examples: Apple's examples are not preserved, but every
concept the guide conveys should be.

## Layout

- `Sources/SwiftLanguageGuideExtended/Documentation.docc/` — the articles.
- `.github/workflows/docs.yml` — builds the DocC archive on every push to
  `main` and deploys it to GitHub Pages.
- `.claude/skills/` — skills describing DocC mechanics and the writing
  conventions for this project.

## Building the docs locally

```
swift package --allow-writing-to-directory ./_site \
  generate-documentation \
  --target SwiftLanguageGuideExtended \
  --disable-indexing \
  --transform-for-static-hosting \
  --hosting-base-path swift-language-guide-extended \
  --output-path ./_site
```

Then serve `_site` over HTTP — opening the files directly with `file://` will
not work, because the rendered page loads its assets by absolute path:

```
python3 -m http.server 8000 --directory _site
```

Open `http://localhost:8000/swift-language-guide-extended/documentation/swiftlanguageguideextended/`.

To preview without the static-hosting transform, `swift package preview-documentation
--target SwiftLanguageGuideExtended` runs a local server that rebuilds on save.
