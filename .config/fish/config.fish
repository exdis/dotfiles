# Path to your oh-my-fish.
set fish_path $HOME/.oh-my-fish

set -gx PATH /usr/local/go/bin $PATH
set -gx GOPATH $HOME/work

function fish_mode_prompt --description "Displays the current mode"
  # Do nothing if not in vi mode
  if set -q __fish_vi_mode
    switch $fish_bind_mode
      case default
        set_color --bold --background red white
        echo ' N '
      case insert
        set_color --bold --background green white
        echo ' I '
      case visual
        set_color --bold --background magenta white
        echo ' V '
    end
    set_color normal
  end
end
# Theme
set fish_theme bobthefish
set fish_key_bindings fish_user_key_bindings
set theme_display_ruby no

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

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-fish/plugins/*)
# Custom plugins may be added to ~/.oh-my-fish/custom/plugins/
# Example format: set fish_plugins autojump bundler

# Path to your custom folder (default path is $FISH/custom)
#set fish_custom $HOME/dotfiles/oh-my-fish

# Load oh-my-fish configuration.
. $fish_path/oh-my-fish.fish

alias ack ack-grep
