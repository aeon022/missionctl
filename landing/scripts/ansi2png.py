#!/usr/bin/env python3
"""ANSI screenshot -> 1200x630 OG image. Usage: ansi2png.py in.ansi out.png"""
import re, sys
from PIL import Image, ImageDraw, ImageFont
sys.path.insert(0, __import__("os").path.dirname(__file__))
from ansi2html import P16, FG, BG, c256

def parse(text):
    st = dict(fg=None, bg=None, bold=False, rev=False); rows = [[]]; pos = 0
    for m in re.finditer(r"\x1b\[([0-9;:]*)([A-Za-z])|\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)", text):
        for ch in text[pos:m.start()]:
            if ch == "\n": rows.append([])
            else: rows[-1].append((ch, st["fg"], st["bg"], st["bold"], st["rev"]))
        pos = m.end()
        if m.group(2) != "m": continue
        a = [int(x) if x else 0 for x in re.split(r"[;:]", m.group(1))] or [0]; i = 0
        while i < len(a):
            n = a[i]
            if n == 0: st.update(fg=None, bg=None, bold=False, rev=False)
            elif n == 1: st["bold"] = True
            elif n == 22: st["bold"] = False
            elif n == 7: st["rev"] = True
            elif n == 27: st["rev"] = False
            elif 30 <= n <= 37: st["fg"] = P16[n - 30]
            elif 90 <= n <= 97: st["fg"] = P16[n - 82]
            elif 40 <= n <= 47: st["bg"] = P16[n - 40]
            elif 100 <= n <= 107: st["bg"] = P16[n - 92]
            elif n == 39: st["fg"] = None
            elif n == 49: st["bg"] = None
            elif n in (38, 48) and i + 1 < len(a):
                if a[i + 1] == 5 and i + 2 < len(a): col = c256(a[i + 2]); i += 2
                elif a[i + 1] == 2 and i + 4 < len(a): col = "#%02x%02x%02x" % tuple(a[i + 2:i + 5]); i += 4
                else: col = None
                if col: st["fg" if n == 38 else "bg"] = col
            i += 1
    for ch in text[pos:]:
        if ch == "\n": rows.append([])
        else: rows[-1].append((ch, st["fg"], st["bg"], st["bold"], st["rev"]))
    return rows

import unicodedata
rows = parse(open(sys.argv[1]).read().rstrip("\n"))
if len(sys.argv) > 3:
    rows = rows[: int(sys.argv[3])]  # crop to the first N terminal rows
wide = lambda ch: unicodedata.east_asian_width(ch) in ("W", "F")
size = 14
reg = ImageFont.truetype("/System/Library/Fonts/Menlo.ttc", size, index=0)
bold = ImageFont.truetype("/System/Library/Fonts/Menlo.ttc", size, index=1)
cw = reg.getlength("M"); lh = 17
W, H = 1200, 630
img = Image.new("RGB", (W, H), "#08090b"); d = ImageDraw.Draw(img)
cols = max(sum(2 if wide(c[0]) else 1 for c in r) for r in rows); pw, ph = cols * cw + 40, len(rows) * lh + 40
x0, y0 = (W - pw) / 2, (H - ph) / 2
d.rounded_rectangle([x0, y0, x0 + pw, y0 + ph], 14, fill=BG, outline="#2a2b3a")
for r, row in enumerate(rows):
    c = 0
    for (ch, fg, bg, b, rev) in row:
        f, g = fg or FG, bg
        if rev: f, g = (bg or BG), (fg or FG)
        w = 2 if wide(ch) else 1
        x, y = x0 + 20 + c * cw, y0 + 20 + r * lh
        if g: d.rectangle([x, y, x + w * cw, y + lh], fill=g)
        if wide(ch) or ch == "⏱":  # no glyph in the mono font: draw a coloured dot
            d.ellipse([x + cw * (.55 if w == 2 else .1), y + lh * .3, x + cw * (1.45 if w == 2 else .9), y + lh * .3 + cw * .9 * (1 if w == 2 else .8)], fill=f)
        elif ch != " ":
            d.text((x, y), ch, font=bold if b else reg, fill=f)
        c += w
img.save(sys.argv[2], optimize=True)
