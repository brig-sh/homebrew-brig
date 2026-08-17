# Interim cask, written by hand against v0.1.0-rc13. brig's own release
# workflow takes this over on the first stable tag: goreleaser's skip_upload
# is "auto", so it does not publish a cask for a prerelease.
cask "brig" do
  version "0.1.0-rc13"

  on_macos do
    on_intel do
      sha256 "62f3c39e88c1507521388ff9b0c4ffd8c4e16743aea6164819d77d383de6c439"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-darwin-amd64.tar.gz"
    end
    on_arm do
      sha256 "e9a68ddb2ab4727f2ba21b78ece62c1b6762d9cabee48321164e5314de40e79c"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-darwin-arm64.tar.gz"
    end
  end

  on_linux do
    on_intel do
      sha256 "e216a4001788a547a48524ebb7ac7b650e39e830f971a4ed8ca9381f464353a5"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-linux-amd64.tar.gz"
    end
    on_arm do
      sha256 "8bffc560cd8378ef7d027b3ba31075470def1d6272250e213367917451ceb50b"
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
