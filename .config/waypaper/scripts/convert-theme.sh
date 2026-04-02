#!/bin/bash
WAL_JSON="$HOME/.cache/wal/colors.json"
OUTPUT="$HOME/.config/waypaper/style.css"

python3 - <<EOF
import json

with open("$WAL_JSON") as f:
    c = json.load(f)

col = c["colors"]
fg  = c["special"]["foreground"]
bg  = c["special"]["background"]

css = """

@define-color color0  {color0};
@define-color color1  {color1};
@define-color color2  {color2};
@define-color color3  {color3};
@define-color color4  {color4};
@define-color color5  {color5};
@define-color color6  {color6};
@define-color color7  {color7};
@define-color color8  {color8};
@define-color color9  {color9};
@define-color color10 {color10};
@define-color color11 {color11};
@define-color color12 {color12};
@define-color color13 {color13};
@define-color color14 {color14};
@define-color color15 {color15};
@define-color fg {fg};
@define-color bg {bg};

* {{
    font-family: "JetBrainsMono Nerd Font", "Noto Sans", sans-serif;
    font-size: 13px;
    color: @fg;
    border: none;
    box-shadow: none;
    outline: none;
    transition: background-color 150ms ease;
}}

window {{
    background-color: @bg;
}}

headerbar button {{
    background: none;
    background-image: none;
    color: alpha(@fg, 0.5);
    border: none;
    border-radius: 4px;
    padding: 2px 8px;
    min-height: 0;
    min-width: 0;
    box-shadow: none;
}}

headerbar button:hover {{
    background-color: alpha(@fg, 0.06);
    background-image: none;
    color: @fg;
    box-shadow: none;
}}

scrolledwindow,
scrolledwindow > *,
viewport {{
    border: none;
}}

button {{
    background-color: alpha(@color8, 0.06);
    background-image: none;
    border: 1px solid alpha(@color8, 0.25);
    border-image: none;
    box-shadow: none;
    padding: 3px;
    margin: 3px;
    color: @fg;
}}

button:hover {{
    background-color: alpha(@fg, 0.05);
    background-image: none;
    border-color: transparent;
    box-shadow: none;
}}

button:focus {{
    outline: none;
    border-color: transparent;
    box-shadow: none;
    background-image: none;
}}

button:active {{
    background-color: alpha(@fg, 0.08);
    background-image: none;
    box-shadow: none;
    border-color: transparent;
}}

button.highlighted-button {{
    background-color: alpha(@fg, 0.07);
    background-image: none;
    border-color: transparent;
    border: none;
    box-shadow: none;
}}

button.highlighted-button:hover {{
    background-color: alpha(@fg, 0.10);
    background-image: none;
    box-shadow: none;
    border-color: transparent;
}}

button.highlighted-button > image,
button.highlighted-button:hover > image {{
    -gtk-icon-effect: none;
    -gtk-icon-shadow: none;
}}

menu,
.menu {{
    background-color: @bg;
    border: none;
    padding: 4px;
}}

menuitem {{
    background-color: transparent;
    color: @fg;
    border-radius: 4px;
    padding: 5px 10px;
}}

menuitem:hover {{
    background-color: alpha(@fg, 0.06);
}}

entry,
searchentry {{
    background-color: alpha(@fg, 0.06);
    color: @fg;
    border: 1px solid alpha(@fg, 0.08);
    border-radius: 6px;
    padding: 6px 10px;
    caret-color: @fg;
    box-shadow: none;
}}

entry:focus,
searchentry:focus {{
    background-color: alpha(@fg, 0.09);
    border-color: alpha(@fg, 0.15);
    box-shadow: none;
}}

scrollbar {{
    background-color: transparent;
    min-width: 4px;
    border: none;
}}

scrollbar trough {{
    background-color: transparent;
    border: none;
}}

scrollbar slider {{
    background-color: alpha(@fg, 0.10);
    border-radius: 4px;
    min-width: 4px;
    min-height: 24px;
    margin: 2px;
    border: none;
}}

scrollbar slider:hover {{
    background-color: alpha(@fg, 0.20);
}}

label {{
    color: @fg;
}}

label.dim-label,
label.subtitle {{
    color: alpha(@fg, 0.45);
    font-size: 12px;
}}

separator {{
    background-color: alpha(@fg, 0.07);
    min-height: 1px;
    min-width: 1px;
}}

tooltip {{
    background-color: shade(@bg, 1.3);
    color: @fg;
    border-radius: 6px;
    padding: 4px 10px;
}}

checkbutton {{
    color: @fg;
    padding: 2px 4px;
}}

checkbutton check {{
    background-color: alpha(@fg, 0.07);
    border-radius: 4px;
    min-width: 16px;
    min-height: 16px;
}}

checkbutton check:checked {{
    background-color: alpha(@color8, 0.25);
    color: @fg;
}}

progressbar trough {{
    background-color: alpha(@fg, 0.07);
    border-radius: 4px;
    min-height: 3px;
}}

progressbar progress {{
    background-color: alpha(@color8, 0.40);
    border-radius: 4px;
    min-height: 3px;
}}
""".format(
    color0=col["color0"],   color1=col["color1"],
    color2=col["color2"],   color3=col["color3"],
    color4=col["color4"],   color5=col["color5"],
    color6=col["color6"],   color7=col["color7"],
    color8=col["color8"],   color9=col["color9"],
    color10=col["color10"], color11=col["color11"],
    color12=col["color12"], color13=col["color13"],
    color14=col["color14"], color15=col["color15"],
    fg=fg, bg=bg
)

with open("$OUTPUT", "w") as f:
    f.write(css)

print("style.css waypaper mis à jour !")
EOF
