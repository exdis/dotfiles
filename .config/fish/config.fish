# Path to your oh-my-fish.
set -gx OMF_PATH "$HOME/.local/share/omf"

# Customize Oh My Fish configuration path.
set -gx OMF_CONFIG "$HOME/.config/omf"

# Load oh-my-fish configuration.
source $OMF_PATH/init.fish

set -gx PATH /usr/local/go/bin /usr/local/bin $PATH
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

alias ack ack-grep

alias ssh='env TERM=xterm ssh'
