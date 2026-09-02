---
name: building-docs
description: How to build, serve, and deploy this site's DocC documentation — the docs.sh script, what each command does, and the two build shapes (local and hosted). Use when building the docs, previewing a change in a browser, debugging the rendered site, or touching the Pages workflow.
---

# Building the Docs

Every documentation build goes through `scripts/docs.sh` in this skill
directory. Do not run `swift package generate-documentation` by hand — the
flags differ between a local build and a deployed one, and getting them wrong
produces a site that renders blank.

```
.agents/skills/building-docs/scripts/docs.sh <command>
```

| Command | What it does |
| --- | --- |
| `build` | Compiles the snippets, then builds `_site` for local viewing. |
| `build --hosted` | The deployed shape: adds the hosting base path and the root redirect. This is what CI runs. |
| `serve [--port N]` | Builds, then serves `_site` in the background and prints the URL. Picks a free port from 8000 unless given one. |
| `stop` | Stops that background server. |
| `status` | Prints the running server's URL, or says none is running. |
| `preview` | `swift package preview-documentation` — rebuilds on save, runs in the foreground until interrupted. |

## Which command to use

`serve` for anything you want to look at in a browser. It leaves the server
running across turns, so a later `serve` after an edit reuses the same
workflow: rebuild, restart, print the URL. Stop it with `stop` when done.

`build` alone when the question is whether the build succeeds or what DocC
emitted, and nothing needs to be viewed.

`build --hosted` only to reproduce something that appears on the deployed site
and not locally. The output cannot be served from `_site` directly; see below.

`preview` blocks the terminal, so it suits a person watching a file as they
edit it, not an agent.

## Say what was updated

Every turn that rebuilds or publishes the site ends with a status line, after
everything else in the reply — the summary of the change, the file links, any
caveats. It is the last thing on screen so the state of the two copies of the
site is never something the reader has to reconstruct.

The line links each page that changed on the local server, at its own URL
rather than the site root, so the reader can open it from the reply. An
article's URL is its filename lowercased:

```
http://localhost:8000/documentation/swiftlanguageguideextended/checkingapiavailability
```

That link exists only while a server is running, so use `serve` rather than
`build` for any change worth looking at, and take the port from what it printed.

```
Docs updated locally: <local page URL>
Docs updated locally (<local page URL>) and live.
```

Link every page a change touched. When that list would run longer than the
summary, link the landing page and name the pages in the summary above.

"Live" means the Pages deploy finished, not that the commit was pushed. When
the push has landed but the workflow is still running, say so:

```
Docs updated locally: <local page URL>. The live site is still deploying.
```

## Why there are two build shapes

The deployed site lives under `https://gestrich.github.io/swift-language-guide-extended/`,
so its build passes `--hosting-base-path swift-language-guide-extended`. That
flag prefixes every asset URL with the repo name. Serving such a build from
`_site` gives a blank page: the HTML asks for `/swift-language-guide-extended/css/…`
while the server has `css/` at its root. Reproducing the deployed layout means
serving a parent directory that contains `swift-language-guide-extended` as a
directory or a symlink to `_site`.

Local builds leave the flag off, so `_site` is the server root and the landing
page is at `/documentation/swiftlanguageguideextended/`.

Neither build can be opened with `file://`. The rendered page loads its assets
by absolute path, which resolves against the filesystem root and finds nothing.

## Snippets

`docs.sh` runs `swift build` before every documentation build because only that
compiles the files under `Snippets/`. The documentation build extracts snippets
textually and never type checks them, so a broken example renders fine and
ships wrong.

## CI

`.github/workflows/docs.yml` calls the same script — `docs.sh build --hosted` —
after installing the toolchain, so a build that works locally works there.
Changes to how the site is built belong in the script, not in the workflow. The
workflow still owns the environment: the Swift toolchain (the Ubuntu-supplied
one lacks DocC's render artifacts), the system libraries, and the Pages upload
and deploy steps.
