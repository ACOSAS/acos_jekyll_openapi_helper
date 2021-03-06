Gem::Specification.new do |s|
    s.name        = 'acos_jekyll_openapi_helper'
    s.version     = '1.4.5'
    s.date        = '2019-05-28'
    s.summary     = "Open API json file helper"
    s.description = "A gem to generate page entries for jekyll sites"
    s.authors     = ["Acos AS"]
    s.email       = 'utvikling@acos.no'
    s.files       = ["lib/acos_jekyll_openapi.rb", "bin/start.rb"]
    s.homepage    =
      'https://rubygems.org/gems/acos_jekyll_openapi_helper'
    s.license       = 'MIT'

    s.add_dependency "json", "~> 2.2"
    s.require_path = "lib"
  end