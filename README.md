# 🚀 Terminal Velocity: Awesome Dotfiles

A high-performance terminal environment optimized for Web Developers. Specifically tailored for **Turborepo, NestJS, Next.js, and Tauri** workflows.

## 🎨 Dual-Core Themes
Switch between **One Dark Pro** (Focus) and **Glass Frosted** (Aesthetic) instantly. This toggles the Starship prompt style and sends OSC escape sequences to change your terminal background/foreground colors.

**Switch Command:** `tt`

## 🛠️ Installation
Run this one-liner on any fresh Linux/WSL instance:
\`\`\`bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/conarwelsh/dotfiles/main/install.sh)"
\`\`\`

## ⌨️ Commands & Aliases Reference

### 🧭 Navigation & Inspection
* `z <query>`: Smart directory jumping (zoxide + fzf). Run `z` without args for an interactive fuzzy-search of your frequent directories.
* `ls`: Modern directory listing with icons and Git status (via eza). Defaults to `ls -lah`.
* `ll`: Detailed long-format listing with icons.
* `lt`: Tree view of the current directory.
* `cat <file>`: Syntax-highlighted file viewing (via bat).
* `c`: Clear terminal screen.

### 🚀 Workspace & Multiplexing
* `dev`: Launch the pre-configured Turborepo workspace in **Zellij**. Opens a split view with your Editor, API logs (NestJS), and Web logs (Next.js).
* `zj`: Start a standard Zellij multiplexer session.
* `lg`: Launch **Lazygit** for a powerful, interactive terminal UI for Git.
* `reload`: Instantly refresh your shell configuration after making changes.

### 📦 Development Workflow (Turborepo / Node / Tauri)
* `t`: Shorthand for `turbo`.
* `td`: Start development mode across the monorepo (`turbo run dev`).
* `tb`: Run production builds (`turbo run build`).
* `sous`: Shorthand for `pnpm exec sous`.
* `tauri`: Shorthand for `cargo tauri`.
* `ni`: (Inherited from pnpm/npm) Install dependencies.

### 󰊢 Git Shortcuts
* `g`: `git`
* `gs`: `git status`
* `ga`: `git add`
* `gaa`: `git add .` (Stage all changes)
* `gc "<msg>"`: `git commit -m`
* `gp`: `git push`
* `gl`: Visual Git log with an ASCII graph and one-line summaries.

---

## 📁 Repository Structure
* `.zshrc`: Core shell configuration and aliases.
* `install.sh`: One-click bootstrap script for new machines.
* `setup_links.sh`: Manages symbolic links for portability.
* `layouts/`: Zellij workspace configurations (e.g., `turbo.kdl`).
* `scripts/`: Utility scripts like the theme toggle.
* `themes/`: Starship prompt profiles.
