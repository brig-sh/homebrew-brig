<p align="center">
  <picture>
    <source media="(prefers-color-scheme: dark)" srcset="assets/brig-mark-on-dark.svg">
    <img alt="brig" src="assets/brig-mark-on-light.svg" width="72">
  </picture>
</p>

# homebrew-brig

The Homebrew tap for [brig](https://github.com/brig-sh/brig): run a coding
agent in a sandbox, with the credentials it needs and none of the ones it
does not.

```bash
brew tap brig-sh/brig
brew trust brig-sh/brig   # brew refuses untrusted third-party taps
brew install --cask brig
brig run claude
```

That pulls in `cosign`, which verifies guest images before they boot.

On macOS you also need `hull`, the microVM runtime. It is not published yet --
it ships today as `urunc-macos`, from a private tap:

```bash
brew tap nofireai/nofire git@github.com:NOFireAI/homebrew-nofire.git
brew install urunc-macos
```

The cask will depend on it directly once that is public. On Linux brig drives
`nerdctl` and needs nothing else.

## What is in here

`Casks/brig.rb`, and nothing else. GoReleaser writes it on each stable
release of `brig-sh/brig` -- do not edit it by hand, the next release
overwrites it. Release candidates are skipped on purpose, so `brew upgrade`
follows stable versions only.

A cask rather than a formula because brig ships pre-compiled binaries, which
is what Homebrew now wants casks for.

## Before the first stable release

The cask arrives with the first stable tag of
[brig-sh/brig](https://github.com/brig-sh/brig); release candidates are
skipped, so that `brew upgrade` follows stable versions only. Until then,
install from source or from a release archive:

```bash
git clone https://github.com/brig-sh/brig && cd brig && make build

# or, from a published release
gh release download --repo brig-sh/brig --pattern 'brig-*-darwin-arm64.tar.gz'
tar xzf brig-*-darwin-arm64.tar.gz
sudo install -m 0755 brig brigd /usr/local/bin/
```

## Verifying what you downloaded

Every release is signed with keyless cosign -- no key to distribute, and none
for us to lose. The signature is bound to the workflow that built it and
recorded in Sigstore's public transparency log:

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

Each release also carries an SPDX SBOM per archive.

## License

Apache-2.0, matching [brig](https://github.com/brig-sh/brig) itself.
