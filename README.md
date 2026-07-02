<div align="center">

# ubuntu_setup

**Your whole machine, in one repository.**

An opinionated, one-command Ubuntu baseline for technical users on Framework laptops.
Clone it, run `./setup/bootstrap.sh`, and be done.

</div>

---

## Quick start

On a clean Ubuntu 24.04 machine:

```sh
git clone https://github.com/etmartinkazoo/ubuntu_setup.git
cd ubuntu_setup
./setup/bootstrap.sh
```

The bootstrap is **idempotent** — safe to re-run — and backs up every file it
replaces to `~/.dotfiles-backup/` before touching it.

## What it does

| Stage | Result |
| :---- | :----- |
| `apt` | Installs the curated package set in [`setup/packages.txt`](setup/packages.txt) |
| `mise` | Installs [mise](https://mise.jdx.dev) and baseline node / ruby / python runtimes |
| `dotfiles` | Symlinks `bash`, `tmux`, and `git` config into `$HOME` |
| `framework` | Applies Framework 13/16 hardware fixes — skipped on other devices |

## Usage

```sh
./setup/bootstrap.sh              # run every step
./setup/bootstrap.sh --only apt   # run one step (apt|mise|dotfiles|framework)
./setup/bootstrap.sh --verify     # check the environment, change nothing
./setup/bootstrap.sh --restore    # relink your most recent backed-up dotfiles
ASSUME_YES=1 ./setup/bootstrap.sh # unattended, no prompts
```

## A baseline, not a cage

Everything is a plain file, laid out to be read and changed. **Fork it**, edit
the dotfiles, add packages, drop in your own setup steps — then pull your
version onto every machine you own. The full documentation covers how.

## Repository layout

```text
ubuntu_setup/
├── setup/          # the installer: bootstrap.sh, packages.txt, steps/
├── dotfiles/       # bash, tmux, git config — symlinked into $HOME
├── src/            # this project's website (Astro) — delete it in your fork
└── README.md
```

## The website

The marketing page and documentation live in this same repo as an
[Astro](https://astro.build) project (Astro 7 · Tailwind v4). It is independent
of the setup and can be removed if you only want the dotfiles.

```sh
npm install
npm run dev      # local dev server
npm run build    # static build → ./dist
```

## License

MIT © Ted Martin. Not affiliated with Canonical or Framework Computer.
