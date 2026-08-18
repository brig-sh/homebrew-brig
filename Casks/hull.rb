# Interim cask, written by hand against v0.1.0-rc11. hull's own release
# workflow takes this over on the first stable tag: goreleaser's
# skip_upload is "auto", so it does not publish a cask for a prerelease.
cask "hull" do
  version "0.1.0-rc11"
  sha256 "707e807b67af0e7f76690866897a66880efcabc6bf6d0cb70c811c14b8b77bea"

  url "https://github.com/brig-sh/hull/releases/download/v#{version}/hull-#{version}-arm64.tar.gz"
  name "hull"
  desc "Run unikernels and sandboxed Linux containers as microVMs on Apple Silicon"
  homepage "https://github.com/brig-sh/hull"

  # No macOS floor on purpose. Tahoe is what we develop and test on, and the
  # caveat says so, but blocking the install means nobody can tell us whether
  # an older release works. arch stays hard: Virtualization.framework on
  # Apple Silicon is the whole product.
  # cosign is what checks the signature on the boot bundle -- the kernel,
  # initrd and guest agent every sandbox boots. Without it on PATH, hull's
  # check returns "no tooling", and under the default mode that is not a
  # refusal: the bundle is fetched, written and booted with a printed warning.
  # So on the shipped install path the one control over the boot chain was off
  # by default, purely because nothing pulled the binary in. brig's cask has
  # always depended on it; hull, which is the thing doing the verifying, did
  # not.
  depends_on formula: "cosign"
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
