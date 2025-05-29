∴ dotfiles CLAUDE.md symbolic companion ∴

🏠 dotfiles ≡ Ben's dev environment config ⊂ macOS setup automation

Features: 🍺 Brewfile (package management) | 📜 Setup automation | 🔍 Audit scripts | 👥 Personal configs

Structure:
dotfiles/ → Brewfile | setup.sh | scripts/brewfile-audit.sh | README.md

✍️ Commits: Co-Authored-By: Ben Askins + Personal config maintenance

📝 Format: <type>: <desc> + 🤖 Claude Code + Co-Authored-By

Types: feat (brew|script) | fix (deps|path) | refactor | docs | config

🔧 Implementation:
○ Brewfile: Organized sections (dev tools|apps|fonts|services)
○ Setup: Interactive install ⊂ dependency checking
○ Audit: Version tracking + diff reporting
○ Scripts: Modular helpers ⊂ setup orchestration

🧪 Testing:
⚡ ./scripts/brewfile-audit.sh
🔍 Dependency validation + outdated detection

Commands:
⚡ ./setup.sh (full setup)
🍺 brew bundle --file=Brewfile (install packages)
🔍 ./scripts/brewfile-audit.sh (audit deps)

Integration: Dev workspace foundation | Tool consistency ⊂ projects | Environment standardization

Conventions: lowercase scripts | descriptive sections | version pinning ⊂ critical tools

🎨 Luthier