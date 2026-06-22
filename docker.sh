
dnet() {
    local rows=()

    while IFS='|' read -r name internal driver containers; do
        mapfile -t sorted < <(
            echo "$containers" |
            tr ',' '\n' |
            sed '/^$/d' |
            sort
        )

        rows+=("$name|$internal|$driver|$(join_multiline "$MULTILINE_DELIM" "${sorted[@]}")")
    done < <(
        docker network ls -q |
        xargs docker network inspect \
          --format '{{.Name}}|{{if .Internal}}true{{else}}false{{end}}|{{.Driver}}|{{range .Containers}}{{.Name}},{{end}}'
    )

    print_table unicode "NETWORK|INTERNAL|DRIVER|CONTAINERS" "${rows[@]}"
}

dt() {
    local rows=()
    declare -A name_map
    declare -A port_map

    # First pass: docker ps
    while IFS=$'\t' read -r id name ports; do
        [ -z "$id" ] && continue

        short_id="${id:0:12}"
        name_map["$short_id"]="$name"
        port_map["$short_id"]="$ports"
    done < <(
        docker ps --format "{{.ID}}\t{{.Names}}\t{{.Ports}}"
    )

    [ ${#name_map[@]} -eq 0 ] && {
        echo "No running containers."
        return
    }

    # Second pass: bulk inspect
    while IFS='|' read -r full_id raw_name network_mode net_ips; do
        [ -z "$full_id" ] && continue

        short_id="${full_id:0:12}"
        name="${name_map[$short_id]}"
        ports="${port_map[$short_id]}"

        if [[ "$network_mode" == host ]]; then
            ip_field="host"
        elif [[ "$network_mode" == container:* ]]; then
            target="${network_mode#container:}"
            ip_field="via:${target:0:12}"
        else
            ip_field=$(split_spaces "$net_ips")
        fi

        port_field=$(split_ports "$ports")

        rows+=("$name|$short_id|$ip_field|$port_field")
    done < <(
        docker ps -q | xargs docker inspect \
            --format '{{.Id}}|{{.Name}}|{{.HostConfig.NetworkMode}}|{{range .NetworkSettings.Networks}}{{.IPAddress}} {{end}}'
    )

    mapfile -t rows < <(
        printf "%s\n" "${rows[@]}" | sort -t'|' -k1,1
    )

    print_table unicode "NAME|ID|IPS|PORTS" "${rows[@]}"
}