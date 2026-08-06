{ ... }:

# WeeChat config, delivered DECLARATIVELY as read-only symlinks from
# home/weechat/*.conf -> ~/.config/weechat/. Every file in ./weechat is
# delivered automatically (drop a file in, rebuild, done).
#
# WeeChat rewrites its own .conf on /save and on quit, which would fail against
# read-only store symlinks -- so home/weechat/weechat.conf has
# `save_config_on_exit = off`. Change settings by editing these files and
# rebuilding, NOT via /set at runtime (runtime /set won't persist).
#
# NOTE: sec.conf (secured passwords) is intentionally NOT managed here -- it
# stays a local, writable file so secrets never enter the repo and WeeChat can
# still manage them. WeeChat's data (logs, scripts) lives in
# ~/.local/share/weechat, which is untouched.
{
  xdg.configFile = builtins.listToAttrs (map (f: {
    name = "weechat/${f}";
    value.source = ./weechat/${f};
  }) (builtins.attrNames (builtins.readDir ./weechat)));
}
