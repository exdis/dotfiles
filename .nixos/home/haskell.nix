{ pkgs, ... }:

# Cross-platform Haskell toolchain: GHC + cabal-install + haskell-language-server.
#
# Imported from ./common.nix, so BOTH hosts get the identical toolchain from the
# same nixpkgs pin. Version coherence is the whole point: nixpkgs builds
# `haskell-language-server` against `haskellPackages.ghc`, and `pkgs.ghc` IS
# that compiler, so the language server can always load a project the local
# compiler produced. What this replaces had no such guarantee:
#   * macOS: `ghc` + `haskell-language-server` from Homebrew, on independent
#     release cadences, outside Nix entirely.
#   * NixOS: `haskell-language-server` in environment.systemPackages and no GHC
#     at all -- a language server with nothing to compile.
#
# Deliberately NOT included:
#   * stack  -- downloads and manages its own GHCs by default, re-introducing
#               exactly the version drift this module exists to remove.
#   * ghcup  -- same reason; the toolchain is pinned by flake.lock instead.
# Per-project toolchains belong in that project's own flake/devShell, which
# shadows these user-profile packages inside `nix develop` / direnv.
{
  home.packages = with pkgs; [
    ghc
    cabal-install
    haskell-language-server
  ];

  # `cabal install` puts executables in ~/.cabal/bin under the classic layout
  # and in ~/.local/bin under the XDG layout (the default for fresh cabal
  # installs); neither is on PATH otherwise. Prepended rather than appended
  # because these are explicitly user-installed binaries. Non-existent dirs are
  # ignored by fish, so shipping both costs nothing.
  #
  # NOTE: on macOS this sits AHEAD of /opt/homebrew/bin, unlike the nix profile
  # dirs that common.nix appends at low priority. That only affects binaries the
  # user installed via cabal, which have no Homebrew counterpart.
  programs.fish.shellInit = ''
    # Haskell (cabal-installed executables)
    set -gx PATH $HOME/.cabal/bin $HOME/.local/bin $PATH
  '';
}
