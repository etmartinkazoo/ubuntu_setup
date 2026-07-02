<div align="center">

# ubuntu_setup

**Your whole machine, in one repository.**

A beautiful, keyboard-driven, private, and hardened Ubuntu baseline for
technical users — built for Framework laptops, runs on any x86_64 machine.
Clone it, run `./setup/bootstrap.sh`, and be done.

</div>

---

## Quick start

On a clean Ubuntu 26.04 machine:

```sh
git clone https://github.com/etmartinkazoo/ubuntu_setup.git
cd ubuntu_setup
./setup/bootstrap.sh
```

The bootstrap is **idempotent** — safe to re-run — and backs up every file it
replaces to `~/.dotfiles-backup/` before touching it.

## Five commitments

- **Beautiful** — herdr themes, a considered prompt, sensible defaults.
- **Keyboard-driven** — herdr panes and vim-style navigation; hands on the home row.
- **Private** — telemetry, crash reporting, and connectivity pings turned off on first run.
- **Hardened** — default-deny firewall, automatic security updates, kernel hardening.
- **Efficient** — kernel 7, powertop auto-tuning, and fast native tools for all-day battery.

## What it does

| Stage | Result |
| :---- | :----- |
| `apt` | Installs the curated package set in [`setup/packages.txt`](setup/packages.txt) |
| `herdr` | Installs [herdr](https://herdr.dev) — the keyboard-driven terminal multiplexer |
| `mise` | Installs [mise](https://mise.jdx.dev) and baseline node / ruby / python runtimes |
| `dotfiles` | Symlinks `bash`, `herdr`, and `git` config into `$HOME` |
| `privacy` | Disables Ubuntu telemetry, crash reporting, and phone-home pings |
| `hardening` | Enables `ufw`, automatic security updates, and kernel/network `sysctl` |
| `power` | powertop auto-tuning + Framework fixes (skipped on other devices) |

## Usage

```sh
./setup/bootstrap.sh              # run every step
./setup/bootstrap.sh --only herdr # run one step (apt|herdr|mise|dotfiles|privacy|hardening|power)
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
├── dotfiles/       # bash, herdr, git config — symlinked into $HOME
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
