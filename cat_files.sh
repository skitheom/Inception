#!/bin/sh

# ディレクトリ指定がなければ現在のディレクトリ
TARGET_DIR="${1:-.}"
GREEN="\033[38;5;82m"
MINT="\033[38;5;121m"
LIME="\033[38;5;118m"
RESET="\033[0m"

find "$TARGET_DIR" -type f | sort | while read -r file; do
  dir=$(dirname "$file")
  if [ "$dir" != "$last_dir" ]; then
    echo "\n${MINT}===== 📂 $dir =====${RESET}"
    last_dir="$dir"
  fi
  echo "\n${LIME}--- $file ---${RESET}"
  cat "$file"
done