# Interim cask, written by hand against v0.1.0-rc3.
#
# GoReleaser writes this file on brig's first STABLE release and will
# overwrite whatever is here, so keep edits to a minimum and mirror what it
# generates. Two differences from the generated one, both deliberate and both
# temporary:
#
#   - it points at a prerelease, because that is the only published version
#   - it does not depend on the hull cask, because hull has no release yet.
#     macOS users build hull from source until it does; see the caveats.
cask "brig" do
  version "0.1.0-rc3"

  on_macos do
    on_intel do
      sha256 "99d4ff07ba8a87878d64281704db305645d3c71d20785077537a80503f1d2394"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-darwin-amd64.tar.gz"
    end
    on_arm do
      sha256 "926b1be25151d15fccad2c0a5f17660509419678cb7f64d251b5b097abb2dd73"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-darwin-arm64.tar.gz"
    end
  end

  on_linux do
    on_intel do
      sha256 "5faf79d454cfcd2e467eaa99b7420ca0e9b159074547dbf20a113e7eb656e9da"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-linux-amd64.tar.gz"
    end
    on_arm do
      sha256 "8c3ec49a3e7973a227b4a5d32ea9e7c1eded382ea7a51589d245ca6ce1658d85"
      url "https://github.com/brig-sh/brig/releases/download/v#{version}/brig-#{version}-linux-arm64.tar.gz"
    end
  end

  name "brig"
  desc "Run a coding agent in a sandbox, with the credentials it needs and none of the ones it does not"
  homepage "https://github.com/brig-sh/brig"

  depends_on formula: "cosign"

  binary "brig"
  binary "brigd"

  postflight do
    # The archives are signed with keyless cosign, which proves where they
    # came from, but Gatekeeper wants a Developer ID signature and a
    # notarization ticket that these binaries do not carry yet. Without this
    # a quarantined download refuses to run at all.
    if OS.mac?
      system_command "/usr/bin/xattr",
                     args: ["-dr", "com.apple.quarantine", "#{staged_path}/brig"]
      system_command "/usr/bin/xattr",
                     args: ["-dr", "com.apple.quarantine", "#{staged_path}/brigd"]
    end
  end

  caveats <<~EOS
    On Linux, brig drives nerdctl and needs nothing else.

    On macOS it drives hull, which has no release yet. Build it from source:

      git clone https://github.com/brig-sh/hull && cd hull && make build

    Guest images are verified with cosign before boot. An image brig-sh did
    not publish is reported and booted anyway. One that claims to be ours and
    fails verification stops and asks.

    Start with:
      brig run claude
  EOS
end
