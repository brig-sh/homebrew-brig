# Interim cask, written by hand against v0.1.0-rc17. brig's own release
# workflow takes this over on the first stable tag: goreleaser's skip_upload
# is "auto", so it does not publish a cask for a prerelease.
cask "brig" do
  version "0.1.0-rc17"

  on_macos do
    on_intel do
      sha256 "db88697fd4618cdbfc24a1da67b7fe0d869456a9658df5008b745169c4815624"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-darwin-amd64.tar.gz"
    end
    on_arm do
      sha256 "4030c2b2f0c1073141cea1528816180bd965be62268904ac6bacca4b4d2cd6fd"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-darwin-arm64.tar.gz"
    end
  end

  on_linux do
    on_intel do
      sha256 "eeac769128d69aba57e1f7f0fd6b13595eddc1a3c26969b57938c579dab92279"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-linux-amd64.tar.gz"
    end
    on_arm do
      sha256 "f77e7350bd0c496c9e0f474e3666564021ef9847792e1acae0cac5a8c64d2f22"
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
