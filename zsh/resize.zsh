#!/bin/bash

resize() {
  local max_height="${1:-1024}" # Default height if not provided
  local input_directory="." # Input directory
  local output_directory="resized-images" # Output directory

  # Create output directory if it doesn't exist
  mkdir -p "$output_directory"

  # Loop through all image files in the input directory
  for image in "$input_directory"/*.{jpg,jpeg,png,gif}; do
    # Check if the file exists (in case no files match the pattern)
    if [[ -f "$image" ]]; then
      # Extract filename and extension
      local filename
      filename=$(basename "$image")

      # Resize the image to the specified max height while keeping aspect ratio
      convert "$image" -resize x"$max_height" "$output_directory/$filename"

      echo "Resized: $image -> $output_directory/$filename"
    fi
  done

  echo "All images have been resized to a max height of $max_height px and saved to $output_directory."
}

# Example usage
# resize 800
