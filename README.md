<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/brig-mark-on-dark.svg">
    <img alt="brig" src="assets/brig-mark-on-light.svg" width="96">
  </picture>
</p>

# homebrew-brig

The Homebrew tap for [brig](https://github.com/brig-sh/brig) and
[hull](https://github.com/brig-sh/hull). brig runs a coding agent inside a
microVM on your own machine; hull is the microVM runtime it drives on macOS.

```bash
brew tap brig-sh/brig
brew trust brig-sh/brig   # Homebrew 6 and later refuse untrusted third-party taps
brew install --cask brig
brig run claude
```

That is the whole install. The `brig` cask depends on the `hull` cask, so one
command brings both. It also pulls in `cosign`, which verifies guest images
before they boot.

To install the runtime on its own, without brig:

```bash
brew install --cask hull
```

On Linux brig drives `nerdctl` with containerd and needs nothing else. hull
runs on macOS on Apple silicon only, and its cask requires `arm64`.

## What is in here

Two casks.

`Casks/brig.rb` installs `brig` and `brigd`, plus the bash, zsh and fish
completions the release archive carries. Homebrew puts each one where its
shell reads completions from, so a cask install has completion with no second
step.

`Casks/hull.rb` installs three executables side by side: `hull`, `vz-runner`
and `hvi`. hull looks for a runner next to its own path, so keep them
together. Two optional extras are worth knowing about: `brew install
e2fsprogs` for the ext4 block rootfs mode, and `brew install qemu` for the
QEMU backend.

Both are casks rather than formulae because brig and hull ship pre-compiled
binaries, which is what Homebrew now wants a cask for.

## How the casks are maintained

By hand, for now. Both repositories generate their cask from GoReleaser, and
both set `skip_upload: auto`, which means no cask is published for a
prerelease. The whole `0.1.0-rc` series is prereleases, so until the first
stable tag these two files are written and pinned here by hand.

At that first stable tag GoReleaser takes over. It opens a pull request
against this repository rather than pushing, so the cask that people install
gets read before it lands. Release candidates stay skipped on purpose, so
`brew upgrade` follows stable versions only.

If the tap ever lags the newest release candidate, brig's
[install.sh](https://github.com/brig-sh/brig/blob/main/docs/install.md#installsh)
installs a specific one.

## Checks

CI runs on every change, because a cask is the one file here that can be
wrong in a way nobody notices.

`brew style` and `brew audit` check that a cask is well-formed.
`script/check-cask-checksums.py` checks that it is honest: it takes the tag
out of each download URL, fetches that release's `checksums.txt` and compares
it with what the cask claims. A cask can be well-formed and still point at
the wrong bytes, so both gates run.

You can run either one locally:

```bash
brew style brig-sh/brig
python3 script/check-cask-checksums.py Casks/*.rb
```

Give `brew style` the tap, not the file paths. The path form skips some of
the cask cops, so it can report clean on a file the tap form rejects.

One thing to expect. GoReleaser writes a cask with its own indentation, and
`brew style` has opinions about it, so the pull request it opens will arrive
with a handful of correctable offences. They are formatting, not substance:

```bash
brew style --fix Casks/brig.rb Casks/hull.rb
```

That clears them. The description length is the offence rubocop cannot
autocorrect, which is why both repositories keep theirs under 80 characters
in `.goreleaser.yaml`.

`brew audit --online` is not in CI yet. It adds two complaints that are true
and not actionable while the casks pin release candidates: the tag is a
GitHub pre-release, and there is no `livecheck` stanza to compare a version
against. Both go away at the first stable tag.

## Verifying what you downloaded

Every release is signed with keyless cosign. There is no key to distribute,
and none for us to lose. The signature is bound to the workflow that built it
and recorded in Sigstore's public transparency log:

```bash
cosign verify-blob \
  --certificate checksums.txt.pem \
  --signature checksums.txt.sig \
  --certificate-identity-regexp \
    '^https://github.com/brig-sh/brig/.github/workflows/release.yml@refs/tags/' \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  checksums.txt

shasum -a 256 -c checksums.txt --ignore-missing
```

The first command answers "was this built by that workflow, in that repo?",
which is the question worth asking. The second ties every archive to the file
that command just vouched for.

For hull, substitute `brig-sh/hull` in the identity regexp.

Each release also carries an SPDX SBOM per archive.

## AI policy

AI-assisted development is welcome in homebrew-brig. See
[AI_POLICY.md](AI_POLICY.md).

## License

Apache-2.0, matching [brig](https://github.com/brig-sh/brig) itself.

---

<p align="center">
  <a href="https://nofire.ai">
    <picture>
      <source media="(prefers-color-scheme: dark)" srcset="assets/nofire-logo-on-dark.svg">
      <img alt="NOFire AI" src="assets/nofire-logo.svg" width="150">
    </picture>
  </a>
</p>

<p align="center">Powered by <a href="https://nofire.ai">NOFire AI</a></p>
