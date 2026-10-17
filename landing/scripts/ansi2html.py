#!/usr/bin/env python3
"""ANSI screenshot -> HTML fragment (inline-styled spans). Usage: ansi2html.py in.ansi > out.html"""
import html, re, sys

P16 = ["#1e1e2e", "#f38ba8", "#a6e3a1", "#f9e2af", "#89b4fa", "#cba6f7", "#94e2d5", "#bac2de",
       "#585b70", "#f38ba8", "#a6e3a1", "#f9e2af", "#89b4fa", "#cba6f7", "#94e2d5", "#cdd6f4"]
FG, BG = "#cdd6f4", "#11111b"

def c256(n):
    if n < 16: return P16[n]
    if n < 232:
        n -= 16; r, g, b = n // 36, n // 6 % 6, n % 6
        f = lambda v: 0 if v == 0 else 55 + 40 * v
        return "#%02x%02x%02x" % (f(r), f(g), f(b))
    v = 8 + 10 * (n - 232); return "#%02x%02x%02x" % (v, v, v)

def convert(text):
    st = dict(fg=None, bg=None, bold=False, dim=False, ul=False, it=False, rev=False)
    out, pos = [], 0
    def style():
        fg, bg = st["fg"], st["bg"]
        if st["rev"]: fg, bg = (bg or BG), (fg or FG)
        css = []
        if fg: css.append("color:" + fg)
        if bg: css.append("background:" + bg)
        if st["bold"]: css.append("font-weight:700")
        if st["dim"]: css.append("opacity:.6")
        if st["ul"]: css.append("text-decoration:underline")
        if st["it"]: css.append("font-style:italic")
        return ";".join(css)
    def emit(s):
        if not s: return
        css = style()
        s = html.escape(s)
        out.append('<span style="%s">%s</span>' % (css, s) if css else s)
    for m in re.finditer(r"\x1b\[([0-9;:]*)([A-Za-z])|\x1b\][^\x07\x1b]*(?:\x07|\x1b\\)|\x1b[()][A-Za-z0-9]", text):
        emit(text[pos:m.start()]); pos = m.end()
        if m.group(2) != "m": continue
        a = [int(x) if x else 0 for x in re.split(r"[;:]", m.group(1))] or [0]
        i = 0
        while i < len(a):
            n = a[i]
            if n == 0: st.update(fg=None, bg=None, bold=False, dim=False, ul=False, it=False, rev=False)
            elif n == 1: st["bold"] = True
            elif n == 2: st["dim"] = True
            elif n == 3: st["it"] = True
            elif n == 4: st["ul"] = True
            elif n == 7: st["rev"] = True
            elif n == 22: st["bold"] = st["dim"] = False
            elif n == 23: st["it"] = False
            elif n == 24: st["ul"] = False
            elif n == 27: st["rev"] = False
            elif 30 <= n <= 37: st["fg"] = P16[n - 30]
            elif 90 <= n <= 97: st["fg"] = P16[n - 90 + 8]
            elif 40 <= n <= 47: st["bg"] = P16[n - 40]
            elif 100 <= n <= 107: st["bg"] = P16[n - 100 + 8]
            elif n == 39: st["fg"] = None
            elif n == 49: st["bg"] = None
            elif n in (38, 48) and i + 1 < len(a):
                if a[i + 1] == 5 and i + 2 < len(a): col = c256(a[i + 2]); i += 2
                elif a[i + 1] == 2 and i + 4 < len(a): col = "#%02x%02x%02x" % tuple(a[i + 2:i + 5]); i += 4
                else: col = None
                if col: st["fg" if n == 38 else "bg"] = col
            i += 1
    emit(text[pos:])
    return "".join(out)

if __name__ == "__main__":
    sys.stdout.write(convert(open(sys.argv[1]).read().rstrip("\n")))
