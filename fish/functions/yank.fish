function yank
    set tmp (mktemp)
    cat > $tmp
    cat $tmp
    cat $tmp | base64 -w 0 | xargs printf '\033]52;c;%s\007'
    rm $tmp
end
