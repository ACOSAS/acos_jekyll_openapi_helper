#!/usr/bin/env ruby

require 'acos_jekyll_openapi'
AcosOpenApiHelper.generate_pages_from_data(
    "/mnt/c/Kode/github/Acos.Integration.Documentation/_data/swagger", 
    "/mnt/c/Kode/github/Acos.Integration.Documentation",
    "/mnt/c/Kode/github/Acos.Integration.Documentation/pages/swagger"
)