# Interim cask, written by hand against v0.1.0-rc15. brig's own release
# workflow takes this over on the first stable tag: goreleaser's skip_upload
# is "auto", so it does not publish a cask for a prerelease.
cask "brig" do
  version "0.1.0-rc15"

  on_macos do
    on_intel do
      sha256 "b5c3ebcdcf652d41c59a2b853d3fbffb41a4f70038dab03b76f6072caac6ad99"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-darwin-amd64.tar.gz"
    end
    on_arm do
      sha256 "38d7d7c4b9e211b8c0901e2d0290953ab851167451f05727fc18b52a9109bfc8"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-darwin-arm64.tar.gz"
    end
  end

  on_linux do
    on_intel do
      sha256 "5445de77b61d132c06ce0931fdca4172a6d428b62a8932d4c70317eb0b2c7926"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-linux-amd64.tar.gz"
    end
    on_arm do
      sha256 "4ee00258820ad3f6b117670f935b8463b86ae9426eaeba77cfa5c4fe4da3634b"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-linux-arm64.tar.gz"
    end
  end

  name "brig"
  desc "Run a coding agent in a sandbox, with the credentials it needs and none of the ones it does not"
  homepage "https://github.com/brig-sh/brig"

  depends_on formula: "cosign"
  # The microVM runtime brig drives on macOS, from this same tap.
  depends_on cask: "brig-sh/brig/hull"

  binary "brig"
  binary "brigd"

  caveats <<~EOS
    On Linux, brig drives nerdctl and needs nothing else.

    Guest images are verified with cosign before boot. An image brig-sh did
    not publish is reported and booted anyway. One that claims to be ours and
    fails verification stops and asks.

    Start with:
      brig run claude
  EOS
end
