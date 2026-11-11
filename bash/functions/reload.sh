_dotfiles_repo="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"

# Re-run setup.sh, reload tmux, then replace this shell with a fresh one to pick up
# the new bashrc. Re-sourcing bashrc instead reloads an attached ble.sh, whose
# terminal queries then echo their replies onto the command line.
reload() {
    "$_dotfiles_repo/setup.sh" || return
    if [[ $TMUX ]]; then
        # catppuccin builds the session pill once and won't rebuild it while it's still set
        tmux set -gu @catppuccin_status_session
        tmux source ~/.tmux.conf
    fi
    # exec skips the history save bash normally does on exit
    history -a
    exec "$BASH"
}
