# Custom XKB package that merges system xkeyboard-config with our custom symbols/keycodes
#
# Usage:
#      export XKB_CONFIG_ROOT=$(nix-build xkb.nix)/etc/X11/xkb

{ pkgs ? import <nixpkgs> {} }:

let
  # Path to this directory (for custom symbols/keycodes)
  customXkbDir = ./.;
in
pkgs.runCommand "xkb-with-dvorak-layouts" {} ''
  mkdir -p $out/share/X11/xkb
  mkdir -p $out/etc/X11

  # Symlink all standard XKB directories
  for dir in compat geometry rules types; do
    ln -s ${pkgs.xkeyboard-config}/share/X11/xkb/$dir $out/share/X11/xkb/$dir
  done

  # Copy symbols and keycodes (so we can add our custom files)
  cp -r ${pkgs.xkeyboard-config}/share/X11/xkb/symbols $out/share/X11/xkb/symbols
  cp -r ${pkgs.xkeyboard-config}/share/X11/xkb/keycodes $out/share/X11/xkb/keycodes
  chmod -R u+w $out/share/X11/xkb/symbols $out/share/X11/xkb/keycodes

  # Add our custom symbol files
  cp ${customXkbDir}/symbols/my_ro $out/share/X11/xkb/symbols/
  cp ${customXkbDir}/symbols/my_ru $out/share/X11/xkb/symbols/

  # Add our custom keycode files
  cp ${customXkbDir}/keycodes/my_evdev_mix4 $out/share/X11/xkb/keycodes/

  # Create /etc/X11/xkb symlink (libxkbcommon on NixOS looks here)
  ln -s $out/share/X11/xkb $out/etc/X11/xkb
''
