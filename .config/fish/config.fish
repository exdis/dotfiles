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

set -gx PATH /usr/local/go/bin /usr/local/bin $GOPATH/bin $PATH
set -gx GOPATH $HOME/dev/golang

function fish_mode_prompt --description "Displays the current mode"
  # Do nothing if not in vi mode
  if set -q __fish_vi_mode
  end
end
# Theme
set fish_theme bobthefish
set fish_key_bindings fish_user_key_bindings
set theme_display_ruby no
set theme_display_vi yes

function fuck -d 'Correct your previous console command'
    set -l exit_code $status
    set -l eval_script (mktemp 2>/dev/null ; or mktemp -t 'thefuck')
    set -l fucked_up_commandd $history[1]
    thefuck $fucked_up_commandd > $eval_script
    . $eval_script
    rm $eval_script
    if test $exit_code -ne 0
        history --delete $fucked_up_commandd
    end
end

function fastcd
    set -l directory $argv[1]
    set -l maxdepth $argv[2]
    set -l target $argv[3]

    set -l chosen (find $directory -maxdepth $maxdepth -name $target \( -type d -or -type l \) -print -quit)

    if test -n chosen
        cd $chosen
    else
        cd $directory
    end
end

alias gocd 'fastcd $GOPATH 3'

complete -c gocd -x -a '( find $GOPATH -maxdepth 1 -type d ! -name ".git" -printf "%f\n" )'

alias dcd 'fastcd $HOME/dev 3'

complete -c dcd -x -a '( find $HOME/dev -maxdepth 1 -type d ! -name ".git" -printf "%f\n" )'

alias ack ack-grep

alias ssh='env TERM=xterm ssh'
