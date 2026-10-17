// The site is authored bilingually (<span class="lang-en">…</span><span class="lang-de">…</span>).
// After the build every page is split into two single-language documents: "/x/" (English) and
// "/de/x/" (German), each with its own <html lang>, title/description, canonical, hreflang and sitemap entry.
import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const SITE = 'https://missionctl.sh';
const here = path.dirname(fileURLToPath(import.meta.url));
const seoDe = JSON.parse(fs.readFileSync(path.join(here, '../src/lib/seo-de.json'), 'utf8'));

/** Remove every element (any tag, nesting-aware) marked for the other language. */
export function filterLang(html, lang) {
  const drop = lang === 'en' ? 'de' : 'en';
  const start = new RegExp(`<([a-zA-Z][a-zA-Z0-9]*)\\b[^>]*\\bclass="[^"]*\\blang-${drop}\\b[^"]*"[^>]*>`, 'g');
  let out = '', pos = 0, m;
  while ((m = start.exec(html))) {
    const tag = m[1];
    const tags = new RegExp(`<${tag}\\b[^>]*>|</${tag}\\s*>`, 'g');
    tags.lastIndex = m.index + m[0].length;
    let depth = 1, e;
    while (depth > 0 && (e = tags.exec(html))) depth += e[0].startsWith('</') ? -1 : e[0].endsWith('/>') ? 0 : 1;
    out += html.slice(pos, m.index);
    pos = tags.lastIndex;
    start.lastIndex = pos;
  }
  return out + html.slice(pos);
}

const esc = (s) => s.replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;');
const swap = (html, from, to) => (from ? html.split(from).join(to).split(esc(from)).join(esc(to)) : html);

/** German pages live under /de/: prefix internal page links (not assets). */
function localizeLinks(html) {
  return html.replace(/<a\b[^>]*>/g, (tag) =>
    tag.replace(/href="(\/[^"]*)"/, (m, href) => {
      if (href.startsWith('//') || href.startsWith('/de/') || href === '/de') return m;
      const p = href.split('#')[0].split('?')[0];
      if (/\.[a-z0-9]+$/i.test(p) || p.startsWith('/_astro')) return m;
      return `href="${href === '/' ? '/de/' : '/de' + href}"`;
    }),
  );
}

function walk(dir) {
  return fs.readdirSync(dir, { withFileTypes: true }).flatMap((d) => {
    const p = path.join(dir, d.name);
    return d.isDirectory() ? (d.name === 'de' || d.name === '_astro' ? [] : walk(p)) : d.name.endsWith('.html') ? [p] : [];
  });
}

export default function i18nSplit() {
  return {
    name: 'i18n-split',
    hooks: {
      'astro:build:done': ({ dir }) => {
        const root = fileURLToPath(dir);
        const urls = [];
        for (const file of walk(root)) {
          const rel = path.relative(root, file);
          if (rel === '404.html') continue;
          const urlPath = '/' + rel.replace(/index\.html$/, '');
          urls.push(urlPath);
          const src = fs.readFileSync(file, 'utf8');
          const enMeta = {
            title: (src.match(/<title>([^<]*)<\/title>/) || [])[1]?.replaceAll('&amp;', '&'),
            description: (src.match(/<meta name="description" content="([^"]*)"/) || [])[1]?.replaceAll('&amp;', '&'),
          };
          const de = seoDe[urlPath] || {};
          const deUrl = SITE + (urlPath === '/' ? '/de/' : '/de' + urlPath);
          const enUrl = SITE + urlPath;
          const altDe = urlPath === '/' ? '/de/' : '/de' + urlPath;

          // English
          let en = filterLang(src, 'en').replaceAll('__ALT_LANG_URL__', altDe);
          fs.writeFileSync(file, en);

          // German
          let h = filterLang(src, 'de');
          h = h.replace('<html lang="en"', '<html lang="de"');
          h = swap(h, enMeta.title, de.title || enMeta.title);
          h = swap(h, enMeta.description, de.description || enMeta.description);
          h = h.split(`rel="canonical" href="${enUrl}"`).join(`rel="canonical" href="${deUrl}"`)
            .split(`property="og:url" content="${enUrl}"`).join(`property="og:url" content="${deUrl}"`)
            .split(`property="twitter:url" content="${enUrl}"`).join(`property="twitter:url" content="${deUrl}"`)
            .split(`name="twitter:url" content="${enUrl}"`).join(`name="twitter:url" content="${deUrl}"`)
            .replace('content="en_US"', 'content="de_DE"').replace('og:locale:alternate" content="de_DE"', 'og:locale:alternate" content="en_US"')
            .replace('"inLanguage":"en"', '"inLanguage":"de"');
          h = localizeLinks(h).replaceAll('__ALT_LANG_URL__', urlPath); // after localizing: the switch must point at the English page
          const out = path.join(root, 'de', rel);
          fs.mkdirSync(path.dirname(out), { recursive: true });
          fs.writeFileSync(out, h);
        }

        // sitemap with hreflang alternates for both language versions
        const entry = (loc, en, de) =>
          `<url><loc>${loc}</loc><xhtml:link rel="alternate" hreflang="en" href="${en}"/><xhtml:link rel="alternate" hreflang="de" href="${de}"/><xhtml:link rel="alternate" hreflang="x-default" href="${en}"/></url>`;
        const body = urls
          .sort()
          .flatMap((u) => {
            const en = SITE + u, de = SITE + (u === '/' ? '/de/' : '/de' + u);
            return [entry(en, en, de), entry(de, en, de)];
          })
          .join('');
        fs.writeFileSync(
          path.join(root, 'sitemap-0.xml'),
          `<?xml version="1.0" encoding="UTF-8"?><urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9" xmlns:xhtml="http://www.w3.org/1999/xhtml">${body}</urlset>`,
        );
      },
    },
  };
}
