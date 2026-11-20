# krepre-site

Static Hugo site for the handle "Krepre", canonical URL https://xn--pck3dscb.com/ (krepre.com redirects to it). No JavaScript, no analytics, one CSS file, one font file. Caddy serves the built files from a Docker container.

## Layout

```
hugo.toml            site config, menus, contact links
content/             _index.md (home), resume/index.md, homelab/index.md, writing/<slug>/index.md (posts)
layouts/             templates
assets/css/main.css  the one stylesheet
assets/logo.*          the home button image; any svg, png, jpg or webp is picked up
static/              font, favicon, resume.pdf
archetypes/          front matter for new posts
scripts/check.sh     fails the build on JavaScript, inline styles, off-site assets or leak patterns
scripts/check.test.sh      self-test for check.sh
scripts/smoke.sh     HTTP checks against a running site
Dockerfile           Hugo build stage, then Caddy serving /srv
Caddyfile            headers, caching, 404 page (container config)
.github/workflows/ci.yml   checks and builds the image
```

## Write a post

```
hugo new content writing/<slug>/index.md
```

Edit it, set `draft: false`, commit and push. Images go next to the post's `index.md`. The Writing link appears in the navigation once the first post is published.

In the post front matter:

```
toc: true              # contents list under the title
cover: "cover.jpg"     # picture under the title, from the post folder
cover_alt: "Describe it"
```

In the text (Hugo makes WebP versions at build time; the gallery is a masonry of thumbnails that each open a larger copy):

```
![What the picture shows](photo.jpg "Caption under it")

{{< gallery "keys-*.jpg" >}}
```

A picture on its own line gets an optional caption from the title, and clicking it opens a larger copy.

To give gallery pictures alt text, add this to the front matter:

```
resources:
  - src: "keys-*.jpg"
    params:
      alt: "Describe them"
```

## Update the resume

Replace `static/resume.pdf` (exported from the LaTeX source, which lives outside this repo) and edit `content/resume/index.md`.

## robots.txt

`layouts/robots.txt` blocks AI training crawlers. Edit it to change the list.

## Preview locally

`hugo server` (Hugo 0.170.0 standard edition, the same version as the Dockerfile; on Windows `winget install Hugo.Hugo.Extended` also works). To run the site checks: `hugo --gc --minify`, then `bash scripts/check.sh public`.

## Leak patterns

`.leak-patterns` (gitignored, one extended regex per line) holds strings that must never appear in the built site. CI reads the same list from the repository secret `LEAK_PATTERNS`. The list is private, which is why it is not committed.

## Bump versions

- Hugo: `HUGO_VERSION` and the checksum on the `ADD` line in the `Dockerfile` (checksum from the release's `hugo_<version>_checksums.txt`, standard `linux-amd64.tar.gz` line).
- Caddy: the image tag in the `Dockerfile`.
- CI tools (gitleaks, lychee): the image tags in `.github/workflows/ci.yml`.
