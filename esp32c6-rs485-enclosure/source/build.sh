#!/bin/sh
# Vyrobí STL na tlač a PNG náhľady z esp32c6_rs485_case.scad
# do ../freestanding a ../din-rail.
set -e
cd "$(dirname "$0")"
scad=esp32c6_rs485_case.scad
fs=../freestanding
din=../din-rail

openscad --backend=manifold -o $fs/esp32c6_rs485_case.stl -D 'part="all"' "$scad"
openscad --backend=manifold -o $fs/preview_body.png -D 'part="body"' \
  --imgsize=1200,900 --camera=48,30,10,55,0,35,260 --colorscheme=Tomorrow "$scad"
openscad --backend=manifold -o $fs/preview_top.png -D 'part="body"' \
  --imgsize=1200,900 --camera=48,30,10,0,0,0,200 --colorscheme=Tomorrow "$scad"
openscad --backend=manifold -o $fs/preview_lid.png -D 'part="lid"' \
  --imgsize=1200,900 --camera=48,30,0,180,0,0,200 --colorscheme=Tomorrow "$scad"

openscad --backend=manifold -o $din/esp32c6_rs485_case_din.stl -D 'part="all_din"' "$scad"
openscad --backend=manifold -o $din/preview_din_assembly.png -D 'part="din_assembly"' \
  --imgsize=1200,900 --camera=48,30,0,70,0,-40,280 --colorscheme=Tomorrow "$scad"
openscad --backend=manifold -o $din/preview_din_clip_side.png -D 'part="din_assembly"' \
  --imgsize=1200,900 --camera=48,30,0,90,0,90,140 --colorscheme=Tomorrow --projection=o "$scad"
openscad --backend=manifold -o $din/preview_din_clip.png -D 'part="clip"' \
  --imgsize=1200,900 --camera=25,0,3,50,0,30,120 --colorscheme=Tomorrow "$scad"
echo "OK: freestanding/ + din-rail/ (STL + preview_*.png)"
