# krepre-site

Static Hugo site for the handle "Krepre", canonical URL https://xn--pck3dscb.com/ (krepre.com redirects to it). No JavaScript, no analytics, one CSS file, one font file. Caddy serves the built files from one Docker container on a home server; a separate reverse proxy handles TLS.

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
scripts/deploy.test.sh     self-test for deploy.sh
scripts/smoke.sh     HTTP checks against a running site
Dockerfile           Hugo build stage, then Caddy serving /srv
Caddyfile            headers, caching, 404 page (container config)
compose.yaml         the single service (image from GHCR), port 8080 on the host
deploy.sh            server-side pull of the new image and restart
deploy/              systemd service and timer for deploy.sh
.github/workflows/ci.yml   checks, publishes the image, then updates the live pointer
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

## How a change goes live

Push to `main`. CI runs the history secret scan, the script self-tests, the image build, `scripts/check.sh`, an offline internal link check and `scripts/smoke.sh` against the container. If all pass, CI pushes the image `ghcr.io/kreprep/krepre-site:<commit>` and then force-pushes the `live` branch, which holds one file, `REVISION`, with the id of that commit. The server's timer reads it, fast-forwards its `main` checkout to that commit and pulls that image, within about 5 minutes. A failed check means nothing is deployed.

## Server setup (once)

Run as `eugene` on the container.

1. Create a read-only deploy key: `ssh-keygen -t ed25519 -f ~/.ssh/site_deploy -N ""`. Add `~/.ssh/site_deploy.pub` under the repository's Settings -> Deploy keys with write access off.
2. Clone the repository: `GIT_SSH_COMMAND='ssh -i ~/.ssh/site_deploy -o IdentitiesOnly=yes' git clone git@github.com:Kreprep/krepre-site.git /docker/site`
3. Pin the key in the checkout: `cd /docker/site && git config core.sshCommand 'ssh -i ~/.ssh/site_deploy -o IdentitiesOnly=yes'`
4. After the first CI run on `main` that pushes an image, on GitHub open the profile's Packages -> krepre-site -> Package settings -> Change visibility -> Public, once. The image holds only the built public pages and the Caddyfile, and public means the server pulls without a login. Public cannot be undone.
5. First deploy: `./deploy.sh`
6. Install and enable the timer: `sudo cp deploy/site-deploy.service deploy/site-deploy.timer /etc/systemd/system/ && sudo systemctl daemon-reload && sudo systemctl enable --now site-deploy.timer`

The units are copied, not linked, so a change in the repository cannot alter what systemd runs as root.

## Operate

- Status and logs: `systemctl list-timers site-deploy.timer`, `journalctl -u site-deploy -n 50`, `docker compose ps`, `docker compose logs site`
- Recreate the container: `docker compose up -d --force-recreate --wait`
- Roll back: revert the commit on `main` and push; CI points `live` at the revert.
- Check the live site: `bash scripts/smoke.sh https://xn--pck3dscb.com`

## Bump versions

- Hugo: `HUGO_VERSION` and the checksum on the `ADD` line in the `Dockerfile` (checksum from the release's `hugo_<version>_checksums.txt`, standard `linux-amd64.tar.gz` line).
- Caddy: the image tag in the `Dockerfile`.
- CI tools (gitleaks, lychee): the image tags in `.github/workflows/ci.yml`.
