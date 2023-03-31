#!/bin/bash

set -e

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

  if [[ "$response_body" == *"Page not found"* ]]; then
    echo "Error: 'Page not found' found in URL - $url"
    return 1
  else
    echo "URL is valid"
    return 0
  fi
}

# Main script
failed=0
for md_file in $(find_md_files); do
  echo "Checking URLs in file: $md_file"
  for url in $(extract_urls "$md_file"); do
    if [[ $url == *"truecharts.org"* ]]; then
      echo "Checking URL: $url"
      if ! check_url "$url"; then
        failed=1
      fi
    fi
  done
done

if [[ $failed -eq 1 ]]; then
  exit 1
fi
