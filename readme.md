# Acos Jekyll Open API json helper
Acos Jekyll Open API helper is a gem written with Jekyll in mind.
The gem produces .md files for all paths in the open api swagger json file.

Version 1.6.0:

- Uses `File.exist?` (Ruby 3 compatible).
- Writes REST stubs and component pages only. Sidebars, overview pages and
  customer text are owned by overlay compose in the documentation repo.
- `generate_pages_from_data(datafolder, basePath, output_path, only_files = [])`
  accepts an optional list of JSON filenames to limit generation.
- Path stubs include `{% include swagger_json/overlay_slot.md slot="after_page" %}`
  after the generated operation body.

From the documentation repo:

```sh
./build_pages.sh
./build_pages.sh arkivmelding.json
```

# Building the gem
```sh
# debug
gem build acos_jekyll_openapi_helper.gemspec -o ./_gems/debug.gem
# debug
gem build acos_jekyll_openapi_helper.gemspec -o ./_gems/release.gem
```
# Publishing the gem
Create an API key with push scope at https://rubygems.org/profile/api_keys, then:

```sh
RUBYGEMS_API_KEY='rubygems_...' ./publish.sh
```

The key is passed to `gem push` as `GEM_HOST_API_KEY` and is not written to the repo.
