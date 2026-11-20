# krepre-site

Static Hugo site for the handle "Krepre", canonical URL https://xn--pck3dscb.com/ (krepre.com redirects to it). No JavaScript, no analytics, one CSS file, one font file. Caddy serves the built files from a Docker container.

## Layout

```
hugo.toml            site config, menus, contact links
content/             _index.md (home), one folder per page or section
layouts/             templates
assets/css/main.css  the one stylesheet
assets/logo.*          the home button image; any svg, png, jpg or webp is picked up
static/              font, favicon, resume.pdf
archetypes/          front matter for new pages and posts
scripts/check.sh     fails the build on JavaScript, inline styles, off-site assets or leak patterns
scripts/check.test.sh      self-test for check.sh
scripts/smoke.sh     HTTP checks against a running site
Dockerfile           Hugo build stage, then Caddy serving /srv
Caddyfile            headers, caching, 404 page (container config)
.github/workflows/ci.yml   checks and builds the image
```

## Preview locally

`hugo server` (Hugo 0.170.0 standard edition, the same version as the Dockerfile; on Windows `winget install Hugo.Hugo.Extended` also works). To run the site checks: `hugo --gc --minify`, then `bash scripts/check.sh public`.

## Leak patterns

`.leak-patterns` (gitignored, one extended regex per line) holds strings that must never appear in the built site. CI reads the same list from the repository secret `LEAK_PATTERNS`. The list is private, which is why it is not committed.

## Bump versions

- Hugo: `HUGO_VERSION` and the checksum on the `ADD` line in the `Dockerfile` (checksum from the release's `hugo_<version>_checksums.txt`, standard `linux-amd64.tar.gz` line).
- Caddy: the image tag in the `Dockerfile`.
- CI tools (gitleaks, lychee): the image tags in `.github/workflows/ci.yml`.
