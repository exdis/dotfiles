{ ... }:

{
  homebrew = {
    enable = true;

    onActivation = {
      cleanup = "none";
      autoUpdate = false;
      upgrade = false;

      extraEnv = {
        HOMEBREW_GITHUB_API_TOKEN = "unused-placeholder-for-nightly-formula-load";
      };
    };

    taps = [
      "azure/functions"
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
      "ghostscript"
      "git-lfs"
      "gleam"
      "glow"
      "gnu-sed"
      "htop"
      "jq"
      "kanata"
      "lgug2z/tap/komorebi-for-mac"
      "lynx"
      "midnight-commander"
      "mitmproxy"
      "mole"
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
      "koekeishiya/formulae/skhd"
      "koekeishiya/formulae/yabai"
      "superfile"
      "thefuck"
      "tldr"
      "tmux"
      { name = "universal-ctags"; args = [ "HEAD" ]; }
      "urlview"
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
