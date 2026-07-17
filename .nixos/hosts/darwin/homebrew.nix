{ ... }:

# Declarative Homebrew (Phase 3).
#
# nix-darwin does NOT install Homebrew; it manages a Brewfile and runs
# `brew bundle` on activation against the existing /opt/homebrew install.
#
# This list encodes the DESIRED end-state, i.e. the machine MINUS the tools
# we've decided are obsolete (see "Retired at Phase 6 cutover" below).
#
# `onActivation.cleanup = "none"`: undeclared packages are NOT auto-removed.
# The Phase 6 cutover originally used cleanup = "uninstall" to make this list
# authoritative, but Homebrew 6.0 deprecated `brew bundle --cleanup` ("no
# replacement") AND that switch deletes ~/.homebrew/trust.json on every run,
# which breaks tap trust (see home/darwin.nix). The migration's removals are
# already done, so we drop cleanup; prune leftover packages manually with
# `brew bundle cleanup` / `brew uninstall` if needed.
#
# Derived from the Phase 0 snapshot ~/.config/migration-snapshot/Brewfile, but:
#   * only LEAVES are declared (explicitly-requested formulae); Homebrew pulls
#     dependency formulae (jpeg-xl, glib, harfbuzz, ...) on its own.
#   * the `npm "..."` / `cargo "..."` blocks from the snapshot are intentionally
#     NOT managed here -- those are npm/cargo globals (auth tooling + dev CLIs),
#     not Homebrew packages, and are churny/work-specific. Left as-is for now.
#
# Retired at the Phase 6 cutover (deliberately absent here; were removed by the
# old cleanup="uninstall", plus brew service stop / yadm rm of their leftover
# configs):
#   taps : felixkratz/formulae, koekeishiya/formulae
#   brews: yabai, skhd, sketchybar          (replaced by AeroSpace)
#   casks: amethyst, phoenix                (other window managers)
#          alacritty, chromedriver          (unused; user-confirmed)
#          font-fira-code-nerd-font         (moved to nixpkgs fonts.packages)
# NOTE: koekeishiya/formulae + skhd were later brought BACK (see taps/brews
# below) to drive komorebi-for-mac, which we're trialling alongside AeroSpace.
# yabai/sketchybar stay retired.
# Also dropped vs snapshot, as no longer needed declaratively:
#   tap homebrew/cask-fonts (archived -> merged into homebrew/cask)
#   tap homebrew/services   (auto-tapped by `brew services`)
{
  homebrew = {
    enable = true;

    onActivation = {
      # See the header comment: cleanup is disabled because Homebrew 6.0
      # deprecated `brew bundle --cleanup` and it wipes the tap trust store.
      cleanup = "none";
      autoUpdate = false;
      upgrade = false;

      # The lgug2z/tap tap ships a `komorebi-for-mac-nightly` formula whose
      # class body unconditionally does `ENV.fetch("HOMEBREW_GITHUB_API_TOKEN")`
      # (it pulls a nightly asset from a private repo). Homebrew evaluates EVERY
      # formula in a tap when it refreshes the description cache during `brew
      # tap`, so that fetch raises "key not found" and aborts the whole tap --
      # even though we only want the STABLE `komorebi-for-mac`, which uses a
      # public release URL and needs no token. Defining the var (any value) lets
      # the nightly formula load; the stable formula never reads it. The value
      # survives Homebrew's re-exec (it keeps HOMEBREW_* vars) and is explicitly
      # excepted from the sensitive-env scrub done before formula eval, so it is
      # present when the nightly formula's class body runs.
      extraEnv = {
        HOMEBREW_GITHUB_API_TOKEN = "unused-placeholder-for-nightly-formula-load";
      };
    };

    taps = [
      "azure/functions"
      # koekeishiya/formulae: re-added for skhd, the hotkey daemon that
      # komorebi-for-mac uses on macOS (~/.config/komorebi/skhdrc). It was
      # retired at the Phase 6 cutover with yabai (see below); skhd itself is
      # just a standalone hotkey daemon, unrelated to yabai, so it's fine to
      # bring back on its own to drive komorebi.
      "koekeishiya/formulae"
      "lgug2z/tap"
      "nikitabobko/tap"
      "oven-sh/bun"
      "powershell/tap"
      "universal-ctags/universal-ctags"
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
      "lgug2z/tap/komorebi-for-mac"
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
      # skhd: hotkey daemon for komorebi-for-mac (config: ~/.config/komorebi/
      # skhdrc, delivered by home/darwin.nix). Run manually while trialling:
      #   skhd --config ~/.config/komorebi/skhdrc
      "skhd"
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
      # ./default.nix); the brew cask was removed during the Phase 6 cutover.
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
