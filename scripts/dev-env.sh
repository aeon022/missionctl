# source scripts/dev-env.sh — switch THIS shell to the dev sandbox:
# dev-built binaries first on PATH, a throwaway HOME, no data-dir/API overrides.
# Close the terminal (or `exec zsh`) to leave it. See TESTING.md.
_root="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/.." && pwd)"
export GOCACHE="$(go env GOCACHE)" GOMODCACHE="$(go env GOMODCACHE)" GOPATH="$(go env GOPATH)"
export MISSIONCTL_REAL_HOME="$HOME"
export HOME="$_root/.dev/home"; mkdir -p "$HOME"
export PATH="$_root/.dev/bin:$PATH"
for v in $(env | cut -d= -f1 | grep -E '_(DATA_DIR|PROVIDER|API_KEY|REFRESH_TOKEN)$'); do unset "$v"; done
echo "dev sandbox: HOME=$HOME  (real data untouched; 'which budgetctl' → $(command -v budgetctl))"
unset _root
