{ ... }:

# Declarative Homebrew (Phase 3).
#
# nix-darwin does NOT install Homebrew; it manages a Brewfile and runs
# `brew bundle` on activation against the existing /opt/homebrew install.
#
# This list encodes the DESIRED end-state, i.e. the current machine MINUS the
# tools we've decided are obsolete (see "Retired at Phase 6 cutover" below).
# During the transition `onActivation.cleanup = "none"`, so nothing is ever
# removed or upgraded -- activation only ensures the declared items are present
# (they already are, so it's effectively a no-op). At the Phase 6 cutover we
# flip cleanup to "zap", at which point everything still installed but no longer
# declared here (the obsolete tools) gets uninstalled automatically.
#
# Derived from the Phase 0 snapshot ~/.config/migration-snapshot/Brewfile, but:
#   * only LEAVES are declared (explicitly-requested formulae); Homebrew pulls
#     dependency formulae (jpeg-xl, glib, harfbuzz, ...) on its own.
#   * the `npm "..."` / `cargo "..."` blocks from the snapshot are intentionally
#     NOT managed here -- those are npm/cargo globals (auth tooling + dev CLIs),
#     not Homebrew packages, and are churny/work-specific. Left as-is for now.
#
# Retired at Phase 6 cutover (deliberately absent here; removed by cleanup="zap"
# once flipped, plus brew uninstall / yadm rm of their leftover configs):
#   taps : felixkratz/formulae, koekeishiya/formulae
#   brews: yabai, skhd, sketchybar          (replaced by AeroSpace)
#   casks: amethyst, phoenix                (other window managers)
#          alacritty, chromedriver          (unused; user-confirmed)
# Also dropped vs snapshot, as no longer needed declaratively:
#   tap homebrew/cask-fonts (archived -> merged into homebrew/cask)
#   tap homebrew/services   (auto-tapped by `brew services`)
{
  homebrew = {
    enable = true;

    # Non-destructive during the transition. Flip cleanup -> "zap" at Phase 6.
    onActivation = {
      cleanup = "none";
      autoUpdate = false;
      upgrade = false;
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
      # font-fira-code-nerd-font: moved to nixpkgs (fonts.packages in
      # ./default.nix). Still installed via brew until the Phase 6 cleanup="zap"
      # removes it; the nixpkgs copy is installed alongside in the meantime.
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
