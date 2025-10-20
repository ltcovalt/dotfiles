#!/usr/bin/env bash

# check if script was sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  IS_SOURCED=false
else
  IS_SOURCED=true
fi

# Enable strict mode only when executed directly (not sourced)
if [[ "$IS_SOURCED" == false ]]; then
  set -Eeuo pipefail
fi

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

create_symlinks() {
  link_dir "$HOME/repos/dotfiles/.config/nvim/" "$HOME/.config/nvim"
}
