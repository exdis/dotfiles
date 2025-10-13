{
  enable = true;
  keyboards = {
    internalKeyboard = {
      devices = [
        "/dev/input/by-path/pci-0000:74:00.4-usb-0:2.3:1.1-event-kbd"
        "/dev/input/by-path/pci-0000:74:00.4-usb-0:2.4:1.0-event-kbd"
        "/dev/input/by-path/pci-0000:74:00.4-usb-0:2.4:1.2-event-kbd"
      ];
      port = 1234;
      extraDefCfg = "process-unmapped-keys yes danger-enable-cmd yes";
      config = ''
(defsrc
  f1   f2   f3   f4   f5   f6   f7   f8   f9   f10   f11   f12
  grv  1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab  q    w    e    r    t    y    u    i    o    p    [    ]    \
  caps a    s    d    f    g    h    j    k    l    ;    '    ret
  lsft z    x    c    v    b    n    m    ,    .    /    rsft
  lctl lmet lalt           spc            ralt rmet rctl
)

(defvar
  tap-time 200
  hold-time 200

  left-hand-keys (
    q w e r t
    a s d f g
    z x c v b
  )
  right-hand-keys (
    y u i o p
    h j k l ;
    n m , . /
    )
)
(deflayer us
  brdn  brup  _    _    _    _   prev  pp  next  mute  vold  volu
  grv     1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab     q    w    e    r    t    y    u    i    o    p    [    ]    \
  esc     @a   @s   @d   @f   g    h    @j   @k   @l   @;    '    ret
  @lshift z    x    c    v    b    n    m    ,    .    /    @rshift
  lctl @lmet lalt           spc            ralt @rmet rctl
)

(deflayer nomods
  brdn  brup  _    _    _    _   prev  pp  next  mute  vold  volu
  grv     1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab     q    w    e    r    t    y    u    i    o    p    [    ]    \
  esc     a    s    d    f    g    h    j    k    l    ;    '    ret
  @lshift z    x    c    v    b    n    m    ,    .    /    @rshift
  lctl @lmet lalt           spc            ralt @rmet rctl
)

(deflayer numpad
  brdn  brup  _    _    _    _   prev  pp  next  mute  vold  volu
  grv     1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab     1    2    3    4    t    y    u    i    o    p    [    ]    \
  esc     5    6    7    8    g    h    j    k    l    ;    '    ret
  @lshift -    =    9    0    b    n    m    ,    .    /    @rshift
  lctl @lmet lalt           spc            ralt @rmet rctl
)

(deflayer nav
  brdn  brup  _    _    _    _   prev  pp  next  mute  vold  volu
  grv     1    2    3    4    5    6    7    8    9    0    -    =    bspc
  tab     q    w    e    r    t    y    u    i    o    p    bspc    ]    \
  esc     a    s    d    f    g    left down up   right ;    '    ret
  @lshift z    x    c    v    b    n    m    ,    .    /    @rshift
  lctl @lmet lalt           spc            ralt @rmet rctl
)

(defalias
  npad (layer-while-held numpad)
)

(defalias
  nnav (layer-while-held nav)
)

(deffakekeys
  to-us (layer-switch us)
)

(defalias
  tap (multi
    (layer-switch nomods)
    (on-idle-fakekey to-us tap 20)
  )

  rmet @npad
  lmet @nnav

  a (tap-hold-release-keys $tap-time $hold-time (multi a @tap)  lctl $left-hand-keys)
  s (tap-hold-release-keys $tap-time $hold-time (multi s @tap) @lmet $left-hand-keys)
  d (tap-hold-release-keys $tap-time $hold-time (multi d @tap)  lsft $left-hand-keys)
  f (tap-hold-release-keys $tap-time $hold-time (multi f @tap)  lmet $left-hand-keys)
  j (tap-hold-release-keys $tap-time $hold-time (multi j @tap)  rmet $right-hand-keys)
  k (tap-hold-release-keys $tap-time $hold-time (multi k @tap)  rsft $right-hand-keys)
  l (tap-hold-release-keys $tap-time $hold-time (multi l @tap) @rmet $right-hand-keys)
  ; (tap-hold-release-keys $tap-time $hold-time (multi ; @tap)  rctl $right-hand-keys)

  lshift (tap-hold-press $tap-time $hold-time C-A-\ lsft)
  rshift (tap-hold-press $tap-time $hold-time C-S-A-\ rsft)
)
      '';
    };
  };
}
