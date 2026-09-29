#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if [[ -z "${RUBYGEMS_API_KEY:-}" ]]; then
  echo "Set RUBYGEMS_API_KEY to a RubyGems API key with push scope." >&2
  echo "Create one at https://rubygems.org/profile/api_keys" >&2
  exit 1
fi

mkdir -p _gems
gem_file="_gems/acos_jekyll_openapi_helper.gem"
gem build acos_jekyll_openapi_helper.gemspec -o "$gem_file"
GEM_HOST_API_KEY="$RUBYGEMS_API_KEY" gem push "$gem_file"
