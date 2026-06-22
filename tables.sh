get_table_colors() {
    TABLE_COLOR=""
    TABLE_RESET=""
    HEADER_COLOR=""

    [[ ! -t 1 ]] && return
    command -v tput >/dev/null 2>&1 || return

    local colors
    colors=$(tput colors 2>/dev/null || echo 0)

    if (( colors >= 256 )); then
        # dark green borders
        TABLE_COLOR=$'\033[38;5;22m'
        HEADER_COLOR=$'\033[38;5;15m'
        TABLE_RESET=$'\033[0m'
    elif (( colors >= 8 )); then
        TABLE_COLOR=$'\033[32m'
        HEADER_COLOR=$'\033[38;5;15m'
        TABLE_RESET=$'\033[0m'
    fi
}

print_table() {
    local style="$1"
    local headers_str="$2"
    shift 2
    local rows=("$@")

    local RS=$'\036'

    # Optional border coloring
    get_table_colors
    local HEADERS_COLOR="${HEADER_COLOR:-}"
    local BORDER_COLOR="${TABLE_COLOR:-}"
    local RESET_COLOR="${TABLE_RESET:-}"

    local TL TR BL BR ML MR H V TJ MJ BJ
    if [[ "$style" == "ascii" ]]; then
        TL="+"; TR="+"
        BL="+"; BR="+"
        ML="+"; MR="+"
        H="-"; V="|"
        TJ="+"; MJ="+"; BJ="+"
    else
        TL="┌"; TR="┐"
        BL="└"; BR="┘"
        ML="├"; MR="┤"
        H="─"; V="│"
        TJ="┬"; MJ="┼"; BJ="┴"
    fi

    repeat_char() {
        local char="$1"
        local count="$2"
        local out=""
        for ((k=0; k<count; k++)); do
            out+="$char"
        done
        printf "%s" "$out"
    }

    local headers=()
    IFS='|' read -ra headers <<< "$headers_str"

    local cols=${#headers[@]}
    local widths=()

    for ((i=0; i<cols; i++)); do
        widths[i]=${#headers[i]}
    done

    for row in "${rows[@]}"; do
        local fields=()
        IFS='|' read -ra fields <<< "$row"

        for ((i=0; i<cols; i++)); do
            local cell="${fields[i]}"
            local lines=()

            IFS="$RS" read -ra lines <<< "$cell"

            for line in "${lines[@]}"; do
                (( ${#line} > widths[i] )) && widths[i]=${#line}
            done
        done
    done

    build_sep() {
        local left="$1"
        local mid="$2"
        local right="$3"

        printf "%s%s%s" "$BORDER_COLOR" "$left" "$RESET_COLOR"

        for ((i=0; i<cols; i++)); do
            printf "%s" "$BORDER_COLOR"
            repeat_char "$H" $((widths[i] + 2))
            printf "%s" "$RESET_COLOR"

            if (( i < cols-1 )); then
                printf "%s%s%s" "$BORDER_COLOR" "$mid" "$RESET_COLOR"
            fi
        done

        printf "%s%s%s\n" "$BORDER_COLOR" "$right" "$RESET_COLOR"
    }

    strip_ansi() {
        sed -r 's/\x1B\[[0-9;]*[mK]//g'
    }

    print_row() {
        local fields=("$@")
        local row_color=""

        # If we have more than the number of columns, assume last arg is color
        if [[ $# -gt cols ]]; then
            row_color="${fields[-1]}"
            fields=("${fields[@]:0:$#-1}")
        fi

        printf "%s%s%s" "$BORDER_COLOR" "$V" "$RESET_COLOR"

        for ((i=0; i<cols; i++)); do
            local raw="${fields[i]}"
            local clean="${raw//\033\[[0-9;]*m/}"

            if [[ -n "$row_color" ]]; then
                local padded
                printf -v padded " %-${widths[i]}s " "$clean"
                printf "%s%s%s" "$HEADER_COLOR" "$padded" "$RESET_COLOR"
            else
                printf " %-${widths[i]}s " "$clean"
            fi

            printf "%s%s%s" "$BORDER_COLOR" "$V" "$RESET_COLOR"
        done

        printf "\n"
    }

    build_sep "$TL" "$TJ" "$TR"
    print_row "${headers[@]}" "$HEADER_COLOR"
    build_sep "$ML" "$MJ" "$MR"

    local row_count=${#rows[@]}

    for ((r=0; r<row_count; r++)); do
        local row="${rows[r]}"
        local fields=()
        IFS='|' read -ra fields <<< "$row"

        local max_lines=1

        for ((i=0; i<cols; i++)); do
            local lines=()
            IFS="$RS" read -ra lines <<< "${fields[i]}"
            (( ${#lines[@]} > max_lines )) && max_lines=${#lines[@]}
        done

        for ((line_idx=0; line_idx<max_lines; line_idx++)); do
            local out=()

            for ((i=0; i<cols; i++)); do
                local lines=()
                IFS="$RS" read -ra lines <<< "${fields[i]}"
                out[i]="${lines[line_idx]}"
            done

            print_row "${out[@]}"
        done

        if (( r < row_count - 1 )); then
            build_sep "$ML" "$MJ" "$MR"
        fi
    done

    build_sep "$BL" "$BJ" "$BR"
}