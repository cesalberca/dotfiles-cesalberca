#!/bin/bash

set -o errexit

# Ensure a parameter is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <screenshot-file>"
  exit 1
fi

screenshot="$1"
base_name=$(basename "${screenshot}" | cut -f 1 -d '.') # Extract the base name without extension
final="${base_name}_3d.png" # Append '3d' to the base name

# Apply perspective transformation
magick "${screenshot}" \
  -alpha Set -virtual-pixel transparent \
  -distort Perspective '0,0 0,0  987,0 987,70  987,810 987,720  0,810 0,810' \
  "${final}"

echo "Final image saved as ${final}"
