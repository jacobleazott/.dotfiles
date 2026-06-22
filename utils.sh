MULTILINE_DELIM=$'\036'

trim() {
    local s="$*"
    s="${s#"${s%%[![:space:]]*}"}"
    s="${s%"${s##*[![:space:]]}"}"
    printf '%s' "$s"
}

join_multiline() {
    local delim="${1:-$MULTILINE_DELIM}"
    shift

    [ $# -eq 0 ] && return

    local out
    out=$(printf "%s$delim" "$@")
    printf "%s" "${out%$delim}"
}

split_ports() {
    local ports="$1"
    local arr=()

    [ -z "$ports" ] && return

    IFS=',' read -ra arr <<< "$ports"

    for i in "${!arr[@]}"; do
        arr[$i]=$(trim "${arr[$i]}")
    done

    join_multiline "$MULTILINE_DELIM" "${arr[@]}"
}

split_spaces() {
    local data="$1"
    local arr=()

    [ -z "$data" ] && return

    IFS=' ' read -ra arr <<< "$data"
    join_multiline "$MULTILINE_DELIM" "${arr[@]}"
}