#!/usr/bin/env bash
# Usage: ./project-structure.sh [path] [depth]
#   path   - root directory (default: script's directory)
#   depth  - max recursion depth (default: 5)
set -euo pipefail

ROOT="${1:-"$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"}"
DEPTH="${2:-5}"
EXCLUDE=('.dart_tool' 'build' '.git' '.idea' '.vscode' '.opencode'
          'windows' 'linux' 'macos' 'assets' 'src' 'docs')

show_tree() {
  local dir="$1" prefix="$2" remaining="$3"
  local items=()
  while IFS= read -r -d '' item; do
    items+=("$item")
  done < <(find "$dir" -maxdepth 1 -mindepth 1 \( -name '.*' -prune -o -print0 \) \
    | sort -z -f -t/ -k2)

  local count=${#items[@]} i=0
  for item in "${items[@]}"; do
    local name
    name="$(basename "$item")"

    local skip=0
    for ex in "${EXCLUDE[@]}"; do
      if [[ "$name" == "$ex" ]]; then skip=1; break; fi
    done
    [[ $skip -eq 1 ]] && { ((i++)) || true; continue; }

    local connector='|-- '
    [[ $((++i)) -eq $count ]] && connector='`-- '
    echo "${prefix}${connector}${name}"

    if [[ -d "$item" && $remaining -gt 0 ]]; then
      local sub_prefix='|   '
      [[ "$connector" == '`-- ' ]] && sub_prefix='    '
      show_tree "$item" "${prefix}${sub_prefix}" $((remaining - 1))
    fi
  done
}

echo "$(basename "$ROOT")/"
show_tree "$ROOT" "" "$DEPTH"
