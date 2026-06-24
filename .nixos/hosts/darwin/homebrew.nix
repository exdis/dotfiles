{ ... }:

# Declarative Homebrew (Phase 3).
#
# nix-darwin does NOT install Homebrew; it manages a Brewfile and runs
# `brew bundle` on activation against the existing /opt/homebrew install.
#
# This list encodes the DESIRED end-state, i.e. the machine MINUS the tools
# we've decided are obsolete (see "Retired at Phase 6 cutover" below).
# `onActivation.cleanup = "uninstall"` (set at the Phase 6 cutover): every brew
# package still installed but no longer declared here is uninstalled on
# activation. This list is now authoritative: anything not declared here is
# removed. (See the onActivation block for why "uninstall" over "zap".)
#
# Derived from the Phase 0 snapshot ~/.config/migration-snapshot/Brewfile, but:
#   * only LEAVES are declared (explicitly-requested formulae); Homebrew pulls
#     dependency formulae (jpeg-xl, glib, harfbuzz, ...) on its own.
#   * the `npm "..."` / `cargo "..."` blocks from the snapshot are intentionally
#     NOT managed here -- those are npm/cargo globals (auth tooling + dev CLIs),
#     not Homebrew packages, and are churny/work-specific. Left as-is for now.
#
# Retired at the Phase 6 cutover (deliberately absent here; removed by
# cleanup="uninstall", plus brew service stop / yadm rm of their leftover
# configs):
#   taps : felixkratz/formulae, koekeishiya/formulae
#   brews: yabai, skhd, sketchybar          (replaced by AeroSpace)
#   casks: amethyst, phoenix                (other window managers)
#          alacritty, chromedriver          (unused; user-confirmed)
#          font-fira-code-nerd-font         (moved to nixpkgs fonts.packages)
# Also dropped vs snapshot, as no longer needed declaratively:
#   tap homebrew/cask-fonts (archived -> merged into homebrew/cask)
#   tap homebrew/services   (auto-tapped by `brew services`)
{
  homebrew = {
    enable = true;

    # Authoritative end-state: uninstall anything not declared here. We use
    # "uninstall" rather than "zap" because zap also deletes app-support files
    # in TCC-protected locations (~/Library/...), which silently fails during
    # activation unless the process has Full Disk Access -- leaving casks only
    # partially removed. "uninstall" reliably removes the package without that
    # dependency (leftover preference files can be cleaned manually if desired).
    onActivation = {
      cleanup = "uninstall";
      autoUpdate = false;
      upgrade = false;
      # Homebrew >=5.x requires explicit confirmation to run a bundle cleanup;
      # nix-darwin's command omits it, so pass it through here non-interactively.
      extraFlags = [ "--force-cleanup" ];
    };

    taps = [
      "azure/functions"
      "nikitabobko/tap"
      "oven-sh/bun"
      "powershell/tap"
      "universal-ctags/universal-ctags"
      "wez/wezterm"
    ];

    brews = [
      "azure-cli"
      "azure/functions/azure-functions-core-tools@4"
      "bat"
      "cabextract"
      "clang-format"
      "cmake"
      "cmatrix"
      "colima"
      "diff-so-fancy"
      "docker"
      "docker-buildx"
      "docutils"
      "exercism"
      "eza"
      "fd"
      "ffmpeg"
      "fish"
      "fzf"
      "gcc"
      "gh"
      "ghc"
      "ghostscript"
      "git-lfs"
      "gleam"
      "glow"
      "gnu-sed"
      "haskell-language-server"
      "htop"
      "jq"
      "kanata"
      "lynx"
      "midnight-commander"
      "mitmproxy"
      "mosquitto"
      "n"
      "ncdu"
      "neofetch"
      "neovim"
      "ninja"
      "nuget"
      "oven-sh/bun/bun"
      # link:false matches the snapshot (avoids clashing with the powershell cask).
      { name = "powershell"; link = false; }
      "pyenv"
      "qemu"
      "ripgrep"
      "superfile"
      "thefuck"
      "tldr"
      "tmux"
      # HEAD build, matching the snapshot.
      { name = "universal-ctags"; args = [ "HEAD" ]; }
      "urlview"
      "weechat"
      "wget"
      "yadm"
      "yazi"
      "zig"
      "zoxide"
    ];

    casks = [
      "nikitabobko/tap/aerospace"
      "browserosaurus"
      "claude-code"
      "dotnet-sdk"
      "emacs-app"
      # font-fira-code-nerd-font moved to nixpkgs (fonts.packages in
      # ./default.nix); the brew cask is removed by cleanup="zap" on activation.
      "font-sf-pro"
      "ghostty"
      "git-credential-manager"
      "linearmouse"
      "powershell"
      "raycast"
      "sf-symbols"
      "wezterm"
      "zed"
    ];
  };
}
