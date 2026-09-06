#!/usr/bin/env sh
# Word counts of everything that ships or specs, working tree vs a git ref (default HEAD).
#   scripts/words.sh          per-file delta vs HEAD, plus the net line for the commit message
#   scripts/words.sh <ref>    same, against <ref>
ref="${1:-HEAD}"
repo="$(cd "$(dirname "$0")/.." && pwd)"; cd "$repo"
files="$( { git ls-files 'skills/*.md' 'contracts/*.md' ARCHITECTURE.md; git ls-files --others --exclude-standard 'skills/*.md' 'contracts/*.md'; } | grep -v '^skills/scaffold-audit/references/' | sort -u)"
tb=0; ta=0
for f in $files; do
    b=$(git show "$ref:$f" 2>/dev/null | wc -w | tr -d ' '); a=$( [ -f "$f" ] && wc -w < "$f" | tr -d ' ' || echo 0)
    tb=$((tb+b)); ta=$((ta+a))
    [ "$a" != "$b" ] && printf '%6d -> %6d  %+6d  %s\n' "$b" "$a" "$((a-b))" "$f"
done
printf 'words: %d -> %d (%+d) vs %s\n' "$tb" "$ta" "$((ta-tb))" "$ref"
