# Inside tmux, title the pane with the ssh destination before connecting, so tmux names the window
# after the host even when the remote never sends a title of its own (no dotfiles there).
# `ssh -G` resolves the destination the same way ssh will; its `host` line is the name as typed.
function _ssh_title {
  [[ -n $TMUX ]] && printf '\e]2;%s\a' "$(command ssh -G "$@" 2>/dev/null | awk '$1 == "host" { print $2; exit }')"
}

function ssh {
  _ssh_title "$@"
  command ssh "$@"
}
