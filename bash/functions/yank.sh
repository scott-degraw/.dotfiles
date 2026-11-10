yank() {
    local tmp
    tmp=$(mktemp)
    cat >"$tmp"
    cat "$tmp"
    printf '\033]52;c;%s\007' "$(base64 <"$tmp" | tr -d '\n')"
    rm "$tmp"
}
