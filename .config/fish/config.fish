# If we get a value for _any_ language variable, we assume we've inherited something sensible to skip all this
# and to allow the user to set it at runtime without mucking with config files.
# This isn't actually our job, so there's a bunch of edge-cases we _cannot_ handle properly.
# In general this breaks the expectation that an empty LANG will be the same as LANG=POSIX.
# Note the missing LC_ALL - locale.conf doesn't allow it.
set -l LANGVARS LANG LANGUAGE LC_CTYPE LC_NUMERIC LC_TIME LC_COLLATE LC_MONETARY LC_MESSAGES LC_PAPER LC_NAME LC_ADDRESS LC_TELEPHONE LC_MEASUREMENT LC_IDENTIFICATION
if not string length -q -- $$LANGVARS
    # Unset the variables since they are empty anyway, and this simplifies our code later.
    for var in $LANGVARS
        set -e $var
    end
    # First read from the kernel commandline.
    # The splitting here is a bit weird, but we operate under the assumption that the locale can't include whitespace.
    # Other whitespace shouldn't concern us, but a quoted "locale.LANG=SOMETHING" as a value to something else might.
    if test -r /proc/cmdline
        for var in (string match -r 'locale.[^=]+=\S+' < /proc/cmdline)
            set -gx (string replace 'locale.' '' -- $var | string split '=')
        end
    end
    # Now try locale.conf - a systemd invention, so I'm not sure if Slackware has it.
    set -l f
    if test -r "$XDG_CONFIG_HOME/locale.conf"
        set f $XDG_CONFIG_HOME/locale.conf
    else if test -r ~/.config/locale.conf
        set f ~/.config/locale.conf
    else if test -r /etc/locale.conf
        set f /etc/locale.conf
    end
    if set -q f[1]
        while read -l kv
            set kv (string split '=' -- $kv)
            if not set -q $kv[1]
                set -gx $kv
            end
        end < $f
    end
end

# Path to your oh-my-fish.
set -gx OMF_PATH "$HOME/.local/share/omf"

# Customize Oh My Fish configuration path.
set -gx OMF_CONFIG "$HOME/.config/omf"

# Load oh-my-fish configuration.
source $OMF_PATH/init.fish

set -gx GOPATH $HOME/dev/golang
set -gx PATH /usr/local/go/bin /usr/local/bin $GOPATH/bin /Applications/Visual\ Studio\ Code.app/Contents/Resources/app/bin /usr/local/sbin $HOME/.cargo/bin $HOME/dev/flutter/bin $HOME/.pub-cache/bin /usr/local/opt/node@14/bin $HOME/.krew/bin $HOME/Library/Python/3.8/bin $PATH

# Java
# set -gx JAVA_HOME (/usr/libexec/java_home -v "1.8")

# Dart
set -gx DART_SDK_PATH /usr/local/opt/dart/libexec
set -gx OVERRIDE_WRIKE_DART_DEPS_BRANCH true
set -gx PUB_HOSTED_URL "http://pub-dev.wrke.in"

# Theme
set fish_key_bindings fish_vi_key_bindings
set fish_theme bobthefish
set theme_display_ruby no
# set theme_color_scheme gruvbox
set theme_display_vi yes
set theme_display_git_master_branch yes

function bobthefish_colors -S -d "Alabaster Dark Custom Colors"
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
end

function fuck -d "Correct your previous console command"
  set -l fucked_up_command $history[1]
  env TF_SHELL=fish TF_ALIAS=fuck PYTHONIOENCODING=utf-8 thefuck $fucked_up_command THEFUCK_ARGUMENT_PLACEHOLDER $argv | read -l unfucked_command
  if [ "$unfucked_command" != "" ]
    eval $unfucked_command
    builtin history delete --exact --case-sensitive -- $fucked_up_command
    builtin history merge
  end
end

alias ssh='env TERM=xterm ssh'

alias vim nvim

alias powershell pwsh

alias la="eza -la --icons=always --git"

set -g TERM "xterm-256color"

set -gx KUBECONFIG $HOME/.kube/config:$HOME/.kube/medallia-kubeconfig

# pip fish completion start
function __fish_complete_pip
    set -lx COMP_WORDS (commandline -o) ""
    set -lx COMP_CWORD ( \
        math (contains -i -- (commandline -t) $COMP_WORDS)-1 \
    )
    set -lx PIP_AUTO_COMPLETE 1
    string split \  -- (eval $COMP_WORDS[1])
end
complete -fa "(__fish_complete_pip)" -c pip3
# pip fish completion end

# pyenv
set -U fish_user_paths $HOME/.pyenv/bin $fish_user_paths
pyenv init - | source
