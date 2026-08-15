# Interim cask, written by hand against v0.1.0-rc8. hull's own release
# workflow takes this over on the first stable tag: goreleaser's
# skip_upload is "auto", so it does not publish a cask for a prerelease.
cask "hull" do
  version "0.1.0-rc8"
  sha256 "b44c2d8d49e592a10648c98b8fbd69bf6f65e6447651915e3f4c3f4563184b26"

  url "https://github.com/brig-sh/hull/releases/download/v#{version}/hull-#{version}-arm64.tar.gz"
  name "hull"
  desc "Run unikernels and sandboxed Linux containers as microVMs on Apple Silicon"
  homepage "https://github.com/brig-sh/hull"

  # No macOS floor on purpose. Tahoe is what we develop and test on, and the
  # caveat says so, but blocking the install means nobody can tell us whether
  # an older release works. arch stays hard: Virtualization.framework on
  # Apple Silicon is the whole product.
  depends_on arch: :arm64

  # vz-runner and hvi sit next to hull: the CLI discovers a runner beside its
  # own executable, and both carry the entitlement their backend needs --
  # virtualization for vz-runner, hypervisor for hvi.
  #
  # hvi has always been in the tarball and was never linked, so a cask install
  # had the vz backend and nothing else. That is no longer a missing extra: the
  # built-in brig profiles ask for hvi by name.
  binary "hull"
  binary "vz-runner"
  binary "hvi"

  caveats <<~EOS
    macOS 26 (Tahoe) on Apple Silicon is the recommended platform, and the
    only one we test. hull installs on earlier macOS releases, but they are
    untested: if you run one, please tell us whether it worked.

    hull boots VMs through Virtualization.framework. Block-rootfs mode wants
    e2fsprogs:

      brew install e2fsprogs
  EOS
end
