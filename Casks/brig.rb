# Interim cask, written by hand against v0.1.0-rc18. brig's own release
# workflow takes this over on the first stable tag: goreleaser's skip_upload
# is "auto", so it does not publish a cask for a prerelease.
cask "brig" do
  version "0.1.0-rc18"

  on_macos do
    on_intel do
      sha256 "b44e4251d4a8c73a648a49effbcb7143713b7b887b80bf24f96a1056d45a4960"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-darwin-amd64.tar.gz"
    end
    on_arm do
      sha256 "be92f420ca24093cad2b00906a857b3874a9c7a9fb395448da03f17bceaada6c"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-darwin-arm64.tar.gz"
    end
  end

  on_linux do
    on_intel do
      sha256 "ea5cd936225560200327c57526b8261fabbcaf39974c24c5b74f0a1014007c51"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-linux-amd64.tar.gz"
    end
    on_arm do
      sha256 "1e26979635891f5a1148c53148d7556ac7677d82c5b8ade82ae4be7b375abfd2"
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
  # Shipped in the archive from v0.1.0-rc18; brew puts each one where its
  # shell reads completions from, as brig's own cask config does.
  bash_completion "completions/brig.bash"
  fish_completion "completions/brig.fish"
  zsh_completion "completions/brig.zsh"

  caveats <<~EOS
    On Linux, brig drives nerdctl and needs nothing else. On macOS it drives
    hull, which brew installed alongside this cask.

    Guest images are verified with cosign before boot. An image brig-sh did
    not publish is reported and booted anyway -- bring-your-own images are a
    supported way to use brig. One that claims to be ours and fails
    verification stops and asks.

    Start with:
      brig run claude
  EOS
end
