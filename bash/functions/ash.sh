# Reconnecting login into a persistent remote tmux session: ash <host>
# autossh restarts ssh when the link dies (exit 255) and re-attaches to `main`; detaching or exiting
# tmux ends ssh cleanly (exit 0), which stops autossh.
# Keepalives here override per-host ServerAliveCountMax so drops are noticed in ~30s, and
# RemoteCommand=none avoids clashing with hosts whose config already sets a RemoteCommand.
unalias ash 2>/dev/null # an older alias in ~/.bashrc would otherwise break this definition
function ash {
  autossh -M 0 -t -o ServerAliveInterval=10 -o ServerAliveCountMax=3 -o RemoteCommand=none \
    "$@" tmux new-session -A -s main
}
