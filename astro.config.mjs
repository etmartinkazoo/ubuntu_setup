// @ts-check
import { defineConfig } from 'astro/config';
import tailwindcss from '@tailwindcss/vite';

// https://astro.build/config
export default defineConfig({
  site: 'https://etmartinkazoo.github.io',
  base: '/ubuntu_setup',
  vite: {
    plugins: [tailwindcss()],
  },
});
