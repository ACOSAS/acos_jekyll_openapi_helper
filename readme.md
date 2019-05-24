# Acos Jekyll Open API json helper
Acos Jekyll Open API helper is a gem written with Jekyll in mind.
The gem produces .md files for all paths in the open api swagger json file.

# Building the gem
```sh
# debug
gem build acos_jekyll_openapi_helper.gemspec -o ./_gems/debug.gem
# debug
gem build acos_jekyll_openapi_helper.gemspec -o ./_gems/release.gem
```
# Publishing the gem
```sh
gem push _gems/release.gem
```

# Save your credentials
```sh
curl -u *rubygems.org email* https://rubygems.org/api/v1/api_key.yaml > ~/.gem/credentials
```
