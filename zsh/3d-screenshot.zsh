#!/bin/bash

set -o errexit

screenshot3d() {
  local screenshot="$1"

  # Ensure a parameter is provided
  if [ -z "${screenshot}" ]; then
    echo "Usage: screenshot3d <screenshot-file>"
    return 1
  fi

  local base_name=$(basename "${screenshot}" | cut -f 1 -d '.') # Extract the base name without extension
  local final="${base_name}_3d.png" # Append '3d' to the base name

  # Apply perspective transformation
  magick "${screenshot}" \
    -alpha Set -virtual-pixel transparent \
    -distort Perspective '0,0 0,0  987,0 987,70  987,810 987,720  0,810 0,810' \
    "${final}"

  echo "Final image saved as ${final}"
}

# Example usage
# screenshot3d "your_screenshot_file.png"
