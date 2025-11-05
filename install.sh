#!/usr/bin/env bash

set -Eeuo pipefail

# creates a symbolic link to a directory
link_dir() {
  local source="$1"
  local dest="$2"

  # ensure parent directories exist
  mkdir -p "$(dirname "$dest")"

  # check if destination directory already exists
  # if so, back it up before creating symlink
  if [[ -d "$dest" ]] && [[ ! -L "$dest" ]]; then
    echo "backing up existing directory: $dest"
    mv "$dest" "$dest.backup.$(date +%s)"
  fi

  # create the symlink
  ln -sfn "$source" "$dest"
  echo "symlink created: $dest -> $source"
}

# creates a symbolic link to a single file
link_file() {
  local source="$1"
  local dest="$2"

  mkdir -p "$(dirname "$dest")"

  # abort if destination is a directory
  if [[ -d "$dest" && ! -L "$dest" ]]; then
    echo "error: '$dest' is a directory, expected a file" >&2
    return 1
  fi

  # if destination file exists and is not a symlink, back it up
  if [[ -e "$dest" && ! -L "$dest" ]]; then
    echo "backing up existing file: $dest"
    mv "$dest" "${dest}.backup.$(date +%s)"
  fi
  
  ln -sfn "$source" "$dest"
  echo "symlink created: $dest -> $source"
}

main() {
  link_dir "$HOME/repos/dotfiles/nvim" "$HOME/.config/nvim"
  link_file "$HOME/repos/dotfiles/prettier/prettierrc.json" "$HOME/.prettierrc.json"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
