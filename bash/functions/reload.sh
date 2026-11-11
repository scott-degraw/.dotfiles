_dotfiles_repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Re-run setup.sh, then pick up the new bashrc and tmux config in this shell
reload() {
    "$_dotfiles_repo/setup.sh" || return
    source ~/.bashrc
    if [[ $TMUX ]]; then
        # catppuccin builds the session pill once and won't rebuild it while it's still set
        tmux set -gu @catppuccin_status_session
        tmux source ~/.tmux.conf
    fi
}
