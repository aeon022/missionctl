// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';
import sitemap from '@astrojs/sitemap';
import i18nSplit from './scripts/i18n-split.mjs';

export default defineConfig({
  site: 'https://missionctl.sh',
  integrations: [sitemap(), i18nSplit()],
  vite: {
    plugins: [tailwindcss()],
  },
});
