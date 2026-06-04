{ pkgs, config, lib, ... }:

let
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # tmux-thumbs "copy to clipboard" command. macOS has pbcopy; Linux picks
  # wl-copy (Wayland) when present, else xclip (X11). The chosen tool must be
  # installed on the host (wl-clipboard / xclip) -- add it in the Linux home.
  thumbsCopy =
    if isDarwin then "pbcopy"
    else "(command -v wl-copy >/dev/null 2>&1 && wl-copy || xclip -selection clipboard)";
in
# Cross-platform home-manager configuration shared between the macOS
# (nix-darwin) and Linux (NixOS) hosts. Keep ONLY things that make sense on
# both platforms here. Host-specific bits live in ./darwin.nix / ./linux.nix.
{
  programs.home-manager.enable = true;

  # --- git --------------------------------------------------------------
  # Faithful port of ~/.gitconfig. Home-manager writes this to
  # ~/.config/git/config, which git reads with LOWER precedence than the
  # legacy ~/.gitconfig. So during the transition the old file keeps winning
  # and nothing changes; cutover = removing ~/.gitconfig from yadm.
  programs.git = {
    enable = true;

    # TRANSITION ONLY (macOS): generate ~/.config/git/config but install NO git
    # binary, so the system's /usr/bin/git stays the active git and nothing
    # changes. On Linux there is no system git, so HM provides the default
    # pkgs.git. At the macOS cutover, drop this and remove ~/.gitconfig.
    package = lib.mkIf isDarwin pkgs.emptyDirectory;

    # Keep machine/work-specific settings (credential helpers, azrepos creds)
    # out of the dotfiles, in untracked ~/.gitlocal.
    includes = [ { path = "~/.gitlocal"; } ];

    settings = {
      user.name = "Denis Kolesnikov";
      user.email = "exdis@proton.me";

      alias = {
        s = "status";
        c = "commit";
        b = "branch";
        co = "checkout";
        ph = "!f() { branch=`git rev-parse --abbrev-ref HEAD`; git push origin $branch; }; f";
        phf = "!f() { branch=`git rev-parse --abbrev-ref HEAD`; git push origin $branch -f; }; f";
        pl = "!f() { branch=`git rev-parse --abbrev-ref HEAD`; git pull origin $branch; }; f";
        plr = "!f() { branch=`git rev-parse --abbrev-ref HEAD`; git pull --rebase origin $branch; }; f";
        pdb = "!f() { branch=`git rev-parse --abbrev-ref HEAD`; git push origin :$branch; }; f";
        r = "rebase";
        ra = "rebase --abort";
        ma = "merge --abort";
        rc = "rebase --continue";
        pr = "!f() { branch=`git rev-parse --abbrev-ref HEAD`; git pull --rebase origin $branch; }; f";
        tree = ''forest --pretty=format:"%C(red)%h %C(magenta)(%ar) %C(blue)%an %C(reset)%s" --style=15 --reverse --all --no-rebase'';
        unstage = "reset HEAD --";
        sync = "!f() { branch=`git rev-parse --abbrev-ref HEAD`; git pull --rebase origin $branch; git co master; git pull; git co $branch; git rebase master; }; f";
        d = ''!f() { [ "$GIT_PREFIX" != "" ] && cd $GIT_PREFIX; git diff --color $@ | diff-so-fancy | less --tabs=4 -RFX; }; f'';
        mt = "mergetool";
      };

      color.ui = "auto";
      core = {
        excludesFile = "~/.gitignore";
        editor = "vim";
      };
      push.default = "simple";
      github.user = "exdis";
      filter."lfs" = {
        smudge = "git-lfs smudge -- %f";
        process = "git-lfs filter-process";
        required = true;
        clean = "git-lfs clean -- %f";
      };
      pull.rebase = false;
      init.defaultBranch = "main";
      merge.tool = "vimdiff";
      mergetool.prompt = true;
      mergetool."vimdiff".cmd = "nvim -d $LOCAL $MERGED $REMOTE";
      difftool.prompt = false;
      diff.tool = "vimdiff";
    };
  };

  # home.stateVersion is intentionally NOT set here; each host sets its own
  # so the two machines can diverge if ever needed.

  # --- tmux -------------------------------------------------------------
  # Home-manager writes ~/.config/tmux/tmux.conf. tmux prefers ~/.tmux.conf
  # when it exists, so during the transition the old file keeps winning;
  # cutover = removing ~/.tmux.conf from yadm.
  #
  # The original config is delivered verbatim via extraConfig. Plugins stay
  # managed by TPM (the original `run '~/.tmux/plugins/tpm/tpm'` is kept),
  # because one plugin (aaronpowell/tmux-weather) isn't packaged in nixpkgs.
  # The tmux-thumbs copy command is parameterized per-platform (see `thumbsCopy`
  # in the let block at the top): pbcopy on macOS, wl-copy/xclip on Linux.
  programs.tmux = {
    enable = true;
    sensibleOnTop = false; # tmux-sensible is already loaded via TPM
    clock24 = true; # match tmux's default 24h clock (baseline would force 12h)

    extraConfig = ''
      # Plugins
      set -g @plugin 'tmux-plugins/tpm'
      set -g @plugin 'tmux-plugins/tmux-sensible'
      set -g @plugin 'tmux-plugins/tmux-urlview'
      set -g @plugin 'aaronpowell/tmux-weather'
      set -g @plugin 'christoomey/vim-tmux-navigator'
      set -g @plugin 'fcsonline/tmux-thumbs'

      # weather
      set -g @forecast-location Prague
      set -g @forecast-format '%c%t'+'|'+'%h'+'|'+'%w'+'|'+'%d'

      # prefix
      unbind C-b
      set-option -g prefix `
      bind-key ` send-prefix

      # split panes
      bind \\ split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # balance panes evenly
      bind m select-layout -E

      # toggle split orientation (vertical <-> horizontal)
      bind Tab if-shell \
        "tmux display-message -p '#{window_layout}' | grep -q '{'" \
        "select-layout even-vertical" \
        "select-layout even-horizontal"

      # reload configuration (HM writes the config here; ~/.tmux.conf is the
      # legacy path that still wins until it's removed from yadm at cutover)
      bind r source-file ~/.config/tmux/tmux.conf

      # panes navigation
      unbind k
      unbind j
      unbind h
      unbind l
      bind -r h select-pane -L
      bind -r l select-pane -R
      bind -r k select-pane -U
      bind -r j select-pane -D

      # window navigation
      unbind n
      unbind p
      bind -r n next-window
      bind -r p previous-window

      # moving windows
      bind -r < swap-window -t -1\; select-window -t -1
      bind -r > swap-window -t +1\; select-window -t +1

      # new window
      unbind t
      bind -r t new-window

      # resizing
      bind -r C-h resize-pane -L 5
      bind -r C-j resize-pane -D 5
      bind -r C-k resize-pane -U 5
      bind -r C-l resize-pane -R 5

      # switch layout
      bind -r l next-layout

      # search
      bind-key / copy-mode \; send-key ?

      # mouse control
      set -g mouse on

      # window list
      setw -g automatic-rename on
      set-window-option -g mode-keys vi
      set-window-option -g automatic-rename off

      # statusbar on top
      set-option -g status-position top

      ## COLORSCHEME: alabaster dark
      set-option -g status "on"
      set -g default-terminal "tmux-256color"
      set-option -ga terminal-overrides ',xterm-256color:Tc'

      # palette reference (for readability):
      # bg0 = #0E1112 (colour233)
      # bg1 = #1E2427 (colour235)
      # fg1 = #DADADA (colour252)
      # accent1 = #99C794 (colour108)
      # accent2 = #6699CC (colour68)
      # accent3 = #FAC863 (colour221)
      # accent4 = #C594C5 (colour176)
      # dim = #2E3235 (colour236)

      # default statusbar color
      set-option -g status-style bg=colour235,fg=colour252

      # default window title colors
      set-window-option -g window-status-style bg=colour236,fg=colour252

      # default window with an activity alert
      set-window-option -g window-status-activity-style bg=colour235,fg=colour108

      # active window title colors
      set-window-option -g window-status-current-style bg=colour68,fg=colour233,bold

      # set inactive/active window styles
      set -g window-style fg=colour247,bg=colour235
      set -g window-active-style fg=colour15,bg=colour233

      # pane border
      set -g pane-border-style fg=colour236,bg=colour235
      set -g pane-active-border-style fg=colour68,bg=colour235

      # message infos
      set-option -g message-style bg=colour236,fg=colour252

      # writing commands inactive
      set-option -g message-command-style bg=colour236,fg=colour252

      # pane number display
      set-option -g display-panes-active-colour colour108
      set-option -g display-panes-colour colour235

      # clock
      set-window-option -g clock-mode-colour colour68

      # bell
      set-window-option -g window-status-bell-style bg=colour176,fg=colour233

      ## Theme settings mixed with colors
      set-option -g status-justify "left"
      set-option -g status-left-style none
      set-option -g status-left-length "80"
      set-option -g status-right-style none
      set-option -g status-right-length "80"
      set-window-option -g window-status-separator ""

      # Statusline segments (soft pastel separators)
      set-option -g status-left "#{?client_prefix,#[bg=colour68],#[bg=colour235]}#[fg=colour252] #S #{?client_prefix,#[fg=colour68],#[fg=colour235]}#[bg=colour235,nobold,noitalics,nounderscore]"
      set-option -g status-right "#[bg=colour235,fg=colour236 nobold, nounderscore, noitalics]#[bg=colour236,fg=colour246] %Y-%m-%d  %H:%M #[bg=colour236,fg=colour252,nobold,noitalics,nounderscore]#[bg=colour252,fg=colour235] #{forecast} #[bg=colour252,fg=colour235] "

      # active window: blue block smoothly blending into status bar
      set-window-option -g window-status-current-format "#[bg=colour68,fg=colour235,nobold,noitalics,nounderscore]#[bg=colour68,fg=colour235] #I #[bg=colour68,fg=colour235,bold] #W#{?window_zoomed_flag,*Z,} #[bg=colour235,fg=colour68,nobold,noitalics,nounderscore]"

      # inactive windows: soft gray blocks
      set-window-option -g window-status-format "#[bg=colour236,fg=colour235,noitalics]#[bg=colour236,fg=colour252] #I #[bg=colour236,fg=colour252] #W #[bg=colour235,fg=colour236,noitalics]"

      # vim
      set-option -s escape-time 10

      # tmux-thumbs (copy command is platform-specific, see thumbsCopy)
      set -g @thumbs-command 'echo -n {} | ${thumbsCopy}'

      # Init TPM
      run '~/.tmux/plugins/tpm/tpm'
    '';
  };

  # --- fish -------------------------------------------------------------
  # Idiomatic port of ~/.config/fish/config.fish. The previous setup used
  # oh-my-fish (OMF) to load the bobthefish theme + bass/z/fzf; those are now
  # pinned from nixpkgs via programs.fish.plugins, so OMF is no longer needed.
  #
  # Dropped during the port (all dead/unwanted, see review notes):
  #   * the Linux-only locale block (read /proc/cmdline, /etc/locale.conf)
  #   * OMF bootstrap (OMF_PATH/OMF_CONFIG + source init.fish) and conf.d/omf.fish
  #   * Wrike Dart env (PUB_HOSTED_URL, OVERRIDE_WRIKE_DART_DEPS_BRANCH) - obsolete
  #   * medallia-kubeconfig entry in KUBECONFIG - obsolete
  #   * stale PATH entries (hardcoded VS Code, flutter, .pub-cache, node@14,
  #     Library/Python/3.8, depot_tools)
  #   * `set -U fish_user_paths $HOME/.pyenv/bin ...` - it mutated universal
  #     state on every load; pyenv's own `pyenv init` handles PATH.
  #
  # The macOS-specific bits are now parameterized per-platform: the /usr/local
  # PATH entries (shellInit) and the `erestart` launchctl logic are guarded by
  # `isDarwin`, with Linux equivalents provided.
  programs.fish = {
    enable = true;

    plugins = [
      { name = "bobthefish"; src = pkgs.fishPlugins.bobthefish.src; }
      { name = "bass"; src = pkgs.fishPlugins.bass.src; }
      { name = "z"; src = pkgs.fishPlugins.z.src; }
      # jethrokuan/fzf (the variant OMF used; respects the existing FZF_*
      # universal vars), NOT PatrickF1/fzf.fish.
      { name = "fzf"; src = pkgs.fishPlugins.fzf.src; }
    ];

    shellAliases = {
      ssh = "env TERM=xterm ssh";
      vim = "nvim";
      powershell = "pwsh";
      la = "eza -la --icons=always --git";
      emc = "emacsclient -nw";
      em = "emacs -nw";
    };

    functions = {
      # bobthefish reads these color_* vars at prompt-paint time. -S
      # (noScopeShadowing) preserves the original semantics.
      bobthefish_colors = {
        description = "Alabaster Dark Custom Colors";
        noScopeShadowing = true;
        body = ''
          # Alabaster Dark palette
          # Base / foreground / background
          set -x color_initial_segment_exit     DADADA B96B55 --bold
          set -x color_initial_segment_private  DADADA 5E87A5
          set -x color_initial_segment_su       DADADA 8DAE8D --bold
          set -x color_initial_segment_jobs     DADADA 5E87A5 --bold

          # Path
          set -x color_path                     1E2427 DADADA
          set -x color_path_basename            1E2427 DADADA --bold
          set -x color_path_nowrite             B96B55 DADADA
          set -x color_path_nowrite_basename    B96B55 DADADA --bold

          # Git / VCS
          set -x color_repo                      AA89AA 1E2427
          set -x color_repo_work_tree            1E2427 DADADA --bold
          set -x color_repo_dirty                B96B55 DADADA
          set -x color_repo_staged               D8B868 1E2427

          # Vi mode
          set -x color_vi_mode_default           DADADA 1E2427 --bold
          set -x color_vi_mode_insert            8DAE8D 1E2427 --bold
          set -x color_vi_mode_visual            D8B868 1E2427 --bold

          # Virtual environments / tools
          set -x color_virtualfish               72A6A6 DADADA --bold
          set -x color_virtualgo                 72A6A6 DADADA --bold
          set -x color_virtualenv                72A6A6 DADADA --bold

          # User / Host
          set -x color_username                  8DAE8D 5E87A5 --bold
          set -x color_hostname                  8DAE8D 5E87A5
        '';
      };

      fuck = {
        description = "Correct your previous console command";
        body = ''
          set -l fucked_up_command $history[1]
          env TF_SHELL=fish TF_ALIAS=fuck PYTHONIOENCODING=utf-8 thefuck $fucked_up_command THEFUCK_ARGUMENT_PLACEHOLDER $argv | read -l unfucked_command
          if [ "$unfucked_command" != "" ]
            eval $unfucked_command
            builtin history delete --exact --case-sensitive -- $fucked_up_command
            builtin history merge
          end
        '';
      };

      erestart = {
        description = "Restart Emacs daemon";
        body =
          if isDarwin then ''
            emacsclient -e '(kill-emacs)' 2>/dev/null
            sleep 1
            rm -f "$TMPDIR"emacs(id -u)/server 2>/dev/null
            launchctl kickstart -k gui/(id -u)/org.gnu.emacs
          '' else ''
            emacsclient -e '(kill-emacs)' 2>/dev/null
            sleep 1
            # If you manage the daemon via systemd (services.emacs), replace the
            # line below with: systemctl --user restart emacs.service
            emacs --daemon
          '';
      };

      __fish_complete_pip = ''
        set -lx COMP_WORDS (commandline -o) ""
        set -lx COMP_CWORD ( \
            math (contains -i -- (commandline -t) $COMP_WORDS)-1 \
        )
        set -lx PIP_AUTO_COMPLETE 1
        string split \  -- (eval $COMP_WORDS[1])
      '';

      fish_user_key_bindings = ''
        for mode in insert default visual
            bind -M $mode \cf forward-char
        end
      '';
    };

    # Runs in every fish (login/non-login/non-interactive): environment + PATH.
    shellInit = ''
      # Go
      set -gx GOPATH $HOME/dev/golang

      # PATH (cross-platform user tool dirs)
      set -gx PATH $GOPATH/bin $HOME/.cargo/bin $HOME/.krew/bin $PATH
      ${lib.optionalString isDarwin ''
      # macOS-only legacy/manual install dirs (manual Go, /usr/local prefix)
      set -gx PATH /usr/local/go/bin /usr/local/bin /usr/local/sbin $PATH''}

      set -gx KUBECONFIG $HOME/.kube/config
    '';

    # Interactive-only: prompt theme, key bindings, cursor, completions.
    interactiveShellInit = ''
      # vi mode + bobthefish theme display options
      set fish_key_bindings fish_vi_key_bindings
      set theme_display_ruby no
      set theme_display_vi yes
      set theme_display_git_master_branch yes

      set -g TERM "xterm-256color"

      # cursor: block in every mode
      set -g fish_cursor_default block
      set -g fish_cursor_insert block
      set -g fish_cursor_replace block
      set -g fish_cursor_visual block

      # pyenv (only when installed; binary comes from fish_user_paths universal var)
      if command -v pyenv >/dev/null 2>&1
        pyenv init - | source
      end

      # pip completion
      complete -fa "(__fish_complete_pip)" -c pip3
    '';
  };

  # --- neovim & emacs ---------------------------------------------------
  # Both editor configs are kept as plain source files (not rewritten as Nix)
  # and delivered via out-of-store symlinks to the live, mutable copies in the
  # flake repo. This is required because their package managers write back into
  # the config dir (nvim: lazy.nvim -> lazy-lock.json; emacs: package.el ->
  # elpa/, eln-cache/, custom.el), which a read-only /nix/store copy forbids.
  # Out-of-store symlinks also make edits live (no rebuild per change).
  #
  # nvim: whole dir (pure source incl. lazy-lock.json).
  # emacs: only the source .el files of the active ~/.config/emacs config (the
  #   retired ~/.config/doom is left unmanaged). The rest of ~/.config/emacs
  #   (generated state + the fff-emacs C module and its fff.nvim Rust build)
  #   stays a real writable dir, so the C module keeps building via `make`.
  xdg.configFile =
    {
      "nvim".source =
        config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixos/home/nvim";

      # --- ghostty & wezterm ------------------------------------------------
      # Static terminal configs: nothing writes back into them, so they are
      # delivered as read-only /nix/store copies (reproducible; editing the
      # source in the flake requires a rebuild to take effect). Unlike git/tmux
      # there is no alternate legacy path here -- the config path IS the XDG
      # path -- so activation is an immediate cutover (the live file is backed
      # up to *.before-hm and replaced by the store symlink).
      "ghostty/config".source = ./ghostty/config;
      "ghostty/themes/alabaster-dark".source = ./ghostty/themes/alabaster-dark;
      "wezterm/wezterm.lua".source = ./wezterm/wezterm.lua;
    }
    // builtins.listToAttrs (map
      (f: {
        name = "emacs/${f}";
        value.source =
          config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.nixos/home/emacs/${f}";
      })
      [ "early-init.el" "init.el" "functions.el" "keybindings.el" "packages.el" ]);

  # --- ctags ------------------------------------------------------------
  # ~/.ctags (universal-ctags config) lives at $HOME, not under XDG. Static,
  # so delivered as a read-only store copy like ghostty/wezterm above.
  home.file.".ctags".source = ./ctags;
}
