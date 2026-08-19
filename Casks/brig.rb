# Interim cask, written by hand against v0.1.0-rc16. brig's own release
# workflow takes this over on the first stable tag: goreleaser's skip_upload
# is "auto", so it does not publish a cask for a prerelease.
cask "brig" do
  version "0.1.0-rc16"

  on_macos do
    on_intel do
      sha256 "b0f784bac29eb0c31d99f38a2674cb811c4af201e9774266959a79f48683e76b"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-darwin-amd64.tar.gz"
    end
    on_arm do
      sha256 "5256cc98604c8247572ed4fb3352426d43a17d1fa9c760406483c480fb0fe83d"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-darwin-arm64.tar.gz"
    end
  end

  on_linux do
    on_intel do
      sha256 "24a7f43905fddc2aeda2a3a6dc3b67bb739049cb769af53b5812949ce9359235"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-linux-amd64.tar.gz"
    end
    on_arm do
      sha256 "aaadfde0ac0a2fd364a4cab3f9a2e6363334ba9321e8715ab18ea656172e465c"
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
