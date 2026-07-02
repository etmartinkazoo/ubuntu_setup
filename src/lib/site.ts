// Prefix an internal path with Astro's configured base so links work
// both locally and when served from a project subpath on GitHub Pages.
const BASE = import.meta.env.BASE_URL.replace(/\/$/, '');

export function href(path: string): string {
  if (path === '/') return BASE || '/';
  return `${BASE}${path.startsWith('/') ? path : `/${path}`}`;
}

export const REPO = 'etmartinkazoo/ubuntu_setup';
export const REPO_URL = `https://github.com/${REPO}`;
export const CLONE_URL = `https://github.com/${REPO}.git`;

export const nav = [
  { label: 'Overview', path: '/' },
  { label: 'Docs', path: '/docs/' },
];

export const docsNav = [
  {
    section: 'Start',
    items: [
      { label: 'Introduction', path: '/docs/' },
      { label: 'Installation', path: '/docs/installation/' },
    ],
  },
  {
    section: 'Reference',
    items: [
      { label: "What's inside", path: '/docs/whats-inside/' },
      { label: 'Repository layout', path: '/docs/layout/' },
    ],
  },
  {
    section: 'Make it yours',
    items: [
      { label: 'Customizing', path: '/docs/customizing/' },
      { label: 'Uninstalling', path: '/docs/uninstalling/' },
    ],
  },
];
