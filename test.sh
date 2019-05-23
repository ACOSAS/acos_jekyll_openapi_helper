#!/usr/bin/env ruby

require 'acos_jekyll_openapi'
AcosOpenApiHelper.generate_pages(
    "/mnt/c/code/github/Acos.Integration.Documentation/_data/swagger/userapi.json", 
    "/mnt/c/code/github/Acos.Integration.Documentation",
    "test", 
    "documentation_sidebar"
)