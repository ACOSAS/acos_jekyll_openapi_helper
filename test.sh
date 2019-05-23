#!/usr/bin/env ruby

require 'acos_jekyll_openapi'
AcosOpenApiHelper.generate_pages_from_data(
    "/mnt/c/code/github/Acos.Integration.Documentation/_data/swagger", 
    "/mnt/c/code/github/Acos.Integration.Documentation",
    "/mnt/c/code/github/Acos.Integration.Documentation/pages/swagger"
)