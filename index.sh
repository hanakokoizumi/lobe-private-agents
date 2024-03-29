#!/bin/bash

WORKING_DIR="$(dirname "$0")/agents"
mkdir -p "$(dirname "$0")/index"

JSON_FILES=("$WORKING_DIR"/[^.]*.[^.]*) 
ZH_CN_FILES=("$WORKING_DIR"/*.zh-CN.json)

declare -a json_tags
declare -a json_agents
declare -a zh_cn_tags
declare -a zh_cn_agents

for file in "${JSON_FILES[@]}"; do
    if [[ $(basename "$file" | tr -cd '.' | wc -c) -eq 1 ]]; then
        content=$(cat "$file")

        content=$(echo "$content" | jq 'del(.config)')

        new_tags=$(echo "$content" | jq -r '.meta.tags[]')
        new_agent=$(echo "$content" | jq -c '.| {author, createAt, homepage, identifier, meta}')

        for tag in $new_tags; do
            if ! [[ "${json_tags[*]}" =~ "$tag" ]]; then
                json_tags+=("$tag")
            fi
        done
        json_agents+=("$new_agent")
    fi
done

jq -c -n --argjson tags "$(jq -c -R -s 'split(" ") | map(rtrimstr("\n"))' <<< "${json_tags[*]}")" --argjson agents "$(jq -c -s '.' <<< "${json_agents[*]}")" '{"schemaVersion":1,"tags":$tags,"agents":$agents}' > "$(dirname "$0")/index/index.json"

for file in "${ZH_CN_FILES[@]}"; do
    content=$(cat "$file")

    content=$(echo "$content" | jq 'del(.config)')

    new_tags=$(echo "$content" | jq -r '.meta.tags[]')
    new_agent=$(echo "$content" | jq -c '.| {author, createAt, homepage, identifier, meta}')

    for tag in $new_tags; do
        if ! [[ "${zh_cn_tags[*]}" =~ "$tag" ]]; then
            zh_cn_tags+=("$tag")
        fi
    done
    zh_cn_agents+=("$new_agent")
done

jq -c -n --argjson tags "$(jq -c -R -s 'split(" ") | map(rtrimstr("\n"))' <<< "${zh_cn_tags[*]}")" --argjson agents "$(jq -c -s '.' <<< "${zh_cn_agents[*]}")" '{"schemaVersion":1,"tags":$tags,"agents":$agents}' > "$(dirname "$0")/index/index.zh-CN.json"