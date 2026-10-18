# nginx-Einstellungen in Plesk (missionctl.sh, postctl.sh)

Domain → *Apache & nginx Settings* → *Additional nginx directives*. **Beide Domains, identischer Inhalt.** Geprüft live am 2026-10-18.
Wichtig: Der **komplette** Block muss drin stehen. Jede Zeile `add_header` fehlt sonst im Ergebnis, und die 404-Umleitung braucht beide `location`-Blöcke.

```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
set $csp "default-src 'self';";
set $csp "${csp} script-src 'self' 'unsafe-inline';";
set $csp "${csp} style-src 'self' 'unsafe-inline';";
set $csp "${csp} img-src 'self' data:; font-src 'self';";
set $csp "${csp} frame-ancestors 'none'; base-uri 'self'; form-action 'self'";
add_header Content-Security-Policy $csp always;
location = /error_docs/not_found.html {
    rewrite ^ /404.html break;
}
location ~ ^/ {
    error_page 404 /404.html;
}
```

## Prüfen
```
curl -sI --compressed https://postctl.sh/ | grep -iE "^(strict|content-security|x-frame|x-content|referrer|permissions)"   # 6 Zeilen
curl -s --compressed https://postctl.sh/nope | grep -o "<title>[^<]*"                                               # eigene 404-Seite
```

## Stolperfallen (alle schon passiert)
- Die CSP als **eine** lange Zeile eingefügt: Zeilenumbruch im Header → „protocol error“ im Browser. Deshalb die `set $csp`-Variante.
- Block nach einer Änderung nur teilweise ersetzt: die fünf anderen Header verschwanden.
- `error_page` allein überschreibt Plesks eigene 404 nicht; beide `location`-Blöcke zusammen tun es.
- Die CSP erlaubt keine fremden Quellen (keine CDNs, keine Frames). Neue externe Skripte/Bilder auf den Seiten brauchen eine bewusste Anpassung.
