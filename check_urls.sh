#!/bin/bash

set -e

# Enable case-insensitive pattern matching
shopt -s nocasematch

# Utility functions
find_md_files() {
  find . -name "*.md"
}

extract_urls() {
  local file=$1
  grep -Eo 'http[s]?://[^ ]+' "$file"
}

check_url() {
  local url=$1
  local response_body
  response_body=$(curl -s -L "$url")

  if [[ "$response_body" == *"Page Not Found"* ]]; then
    echo "Error: 'Page Not Found' found in URL - $url"
    return 1
  else
    echo "URL is valid"
    return 0
  fi
}

# Main script
failed=0
total_urls=0
valid_urls=0
invalid_urls=0

for md_file in $(find_md_files); do
  echo "Checking URLs in file: $md_file"
  for url in $(extract_urls "$md_file"); do
    if [[ $url == *"truecharts.org"* ]]; then
      echo "Checking URL: $url"
      total_urls=$((total_urls+1))
      if check_url "$url"; then
        valid_urls=$((valid_urls+1))
      else
        invalid_urls=$((invalid_urls+1))
        failed=1
      fi
    fi
  done
done

# Display results
echo "---------------------------------------"
echo "Results:"
echo "Total URLs checked: $total_urls"
echo "Valid URLs: $valid_urls"
echo "Invalid URLs: $invalid_urls"
echo "---------------------------------------"

if [[ $failed -eq 1 ]]; then
  exit 1
fi
