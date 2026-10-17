## Development

When starting the dev server, use background mode:

```
astro dev --background
```

Manage the background server with `astro dev stop`, `astro dev status`, and `astro dev logs`.

## Documentation

Full documentation: https://docs.astro.build

Consult these guides before working on related tasks:

- [Adding pages, dynamic routes, or middleware](https://docs.astro.build/en/guides/routing/)
- [Working with Astro components](https://docs.astro.build/en/basics/astro-components/)
- [Using React, Vue, Svelte, or other framework components](https://docs.astro.build/en/guides/framework-components/)
- [Adding or managing content](https://docs.astro.build/en/guides/content-collections/)
- [Adding styles or using Tailwind](https://docs.astro.build/en/guides/styling/)
- [Supporting multiple languages](https://docs.astro.build/en/guides/internationalization/)

## Language split & web server headers (2026-10)

- Pages stay authored bilingually (`lang-en`/`lang-de` pairs). `scripts/i18n-split.mjs` (Astro integration, runs after the build) splits every page into `/…` (EN) and `/de/…` (DE): own `<html lang>`, canonical, hreflang, German title/description from `src/lib/seo-de.json`, sitemap with alternates. **New page → add its German title/description to `seo-de.json`.**
- The language switch is an anchor with the placeholder `__ALT_LANG_URL__`, replaced during the split.
- Mockups: `MISSIONCTL_MOCKUP_DIR=… go test ./cmd -run TestRenderLandingMockups` (in `missionctl/`), then `scripts/ansi2html.py` → `src/mockups/*.html`; OG image: `scripts/ansi2png.py in.ansi public/og-default.png 31`.
- Fonts are self-hosted (`@fontsource/*`); no Google Fonts.
- Set these in Plesk (Apache & nginx → additional nginx directives), plus the 404 page → `/404.html`:

```nginx
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
add_header X-Content-Type-Options "nosniff" always;
add_header X-Frame-Options "DENY" always;
add_header Referrer-Policy "strict-origin-when-cross-origin" always;
add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;
add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; font-src 'self'; frame-ancestors 'none'; base-uri 'self'; form-action 'self'" always;
```
