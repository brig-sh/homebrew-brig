#!/usr/bin/env python3
"""Check every cask against the checksums its release published.

A cask is a promise about bytes: this URL has this sha256. GoReleaser opens a
pull request here on a stable tag, and the one way that pull request can be
wrong in a way nobody notices is for a checksum to disagree with the release it
names. So we ask the release.

For each cask we pull the tag out of the download URL, fetch that release's
checksums.txt once, and compare it with what the cask claims. Needs GH_TOKEN in
the environment for the API; no Homebrew, so it runs anywhere.
"""

import json
import os
import re
import subprocess
import sys
import urllib.request

# Both casks put the sha256 immediately before the url it belongs to, inside
# the same on_arm/on_intel block where there is more than one. So the Nth
# sha256 pairs with the Nth url, and a mismatched count means that assumption
# no longer holds and this script needs a second look.
SHA_RE = re.compile(r'^\s*sha256\s+"([0-9a-f]{64})"', re.M)
URL_RE = re.compile(r'^\s*url\s+"([^"]+)"', re.M)
VERSION_RE = re.compile(r'^\s*version\s+"([^"]+)"', re.M)
TAG_RE = re.compile(r"/releases/download/([^/]+)/")

_checksums_cache = {}


def checksums_for(repo, tag):
    """Return {filename: sha256} from a release's checksums.txt."""
    key = (repo, tag)
    if key in _checksums_cache:
        return _checksums_cache[key]

    out = subprocess.run(
        ["gh", "release", "view", tag, "--repo", repo, "--json", "assets"],
        capture_output=True, text=True, check=True,
    ).stdout
    assets = {a["name"]: a["url"] for a in json.loads(out)["assets"]}
    if "checksums.txt" not in assets:
        sys.exit(f"{repo} {tag}: the release publishes no checksums.txt")

    req = urllib.request.Request(assets["checksums.txt"])
    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN")
    if token:
        req.add_header("Authorization", f"Bearer {token}")
    body = urllib.request.urlopen(req, timeout=60).read().decode()

    table = {}
    for line in body.splitlines():
        parts = line.split()
        if len(parts) == 2:
            table[parts[1]] = parts[0]
    _checksums_cache[key] = table
    return table


def check(path):
    text = open(path).read()
    version = VERSION_RE.search(text)
    if not version:
        sys.exit(f"{path}: no version stanza")
    version = version.group(1)

    shas = SHA_RE.findall(text)
    urls = [u.replace("#{version}", version) for u in URL_RE.findall(text)]
    if len(shas) != len(urls):
        sys.exit(f"{path}: {len(shas)} sha256 stanzas but {len(urls)} urls")
    if not shas:
        sys.exit(f"{path}: no sha256 stanzas")

    failures = []
    for sha, url in zip(shas, urls):
        tag = TAG_RE.search(url)
        if not tag:
            failures.append(f"  {url}: not a release download URL")
            continue
        tag = tag.group(1)
        repo = "/".join(url.split("/")[3:5])
        name = url.rsplit("/", 1)[1]

        published = checksums_for(repo, tag).get(name)
        if published is None:
            failures.append(f"  {name}: {repo} {tag} publishes no checksum for it")
        elif published != sha:
            failures.append(
                f"  {name}:\n    cask      {sha}\n    published {published}"
            )
        else:
            print(f"  ok  {name}")

    if failures:
        print(f"{path}: checksums disagree with the release", file=sys.stderr)
        print("\n".join(failures), file=sys.stderr)
        return False
    return True


if __name__ == "__main__":
    paths = sys.argv[1:]
    if not paths:
        sys.exit("usage: check-cask-checksums.py Casks/*.rb")
    ok = True
    for p in paths:
        print(f"{p}:")
        ok = check(p) and ok
    sys.exit(0 if ok else 1)
