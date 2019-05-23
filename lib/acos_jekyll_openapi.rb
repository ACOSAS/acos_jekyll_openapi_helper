require 'json'

class AcosOpenApiHelper
    def self.generate_pages(json_file, basePath, output_path)

        puts "Loading json file: %s" % [json_file]
        fileHelper = JsonFileHelper.new(json_file)
        fileHelper.load

        engine = PageEngine.new(fileHelper.json_data, basePath, output_path, json_file)
        engine.generate
    end

    def self.generate_pages_from_data(datafolder, basePath, output_path)
        json_files = Dir["%s/*.json" % datafolder]
        json_files.each do | jf |
            puts "Generating pages based on: %s" % jf
            generate_pages(jf, basePath, output_path)
        end

    end
end

class AcosOpenApiHelper::JsonFileHelper
    include JSON
    def initialize(path)
        @path = path
    end

    def path
        @path
    end

    def json_data
        @json_data
    end


    def load
        file = File.read(@path)
        @json_data = JSON.parse(file)        
    end
end

class AcosOpenApiHelper::PageEngine    
    def initialize(data, basePath, output_path, swaggerfile)
        @data = data
        @output_path = output_path
        #@sidebar = sidebar
        @swaggerfile = swaggerfile
        @basePath = basePath
    end        

    def generate
        puts "generating pages..."
        cnt = 0
        puts "Open API version %s" % @data['openapi']
        docTitle = @data["info"]["title"]
        sidebar =  "%s_sidebar" % docTitle
        menu = AcosOpenApiHelper::SidebarMenu.new()
        @data['paths'].each do |path|
            #puts "Prop: %s at counter %s" % [path, cnt]
            _path = path[0] #path of swagger method
            _methods = @data['paths'][_path]
            #puts "Path: %s has methods: %s " % [_path, _methods]
            puts "Methods: %s" % _methods
            puts "Path: %s" % [_path]
            #Should not need this. yet...
            # _methods.each do | _method |
            #     puts "Method: %s " % _method
            #     _md = _methods[_method]
            #     puts "Method description: %s" % [_md]
            # end
            #@prop = @data['paths'][cnt]
            #puts "Found property %s" [@prop]
            #puts "Constants: %s, %s, %s, %s" % [_path, @output_path, @swaggerfile, @sidebar]
            writer =  AcosOpenApiHelper::PageCreator.new(_path, @basePath, @output_path, @swaggerfile, sidebar)
            writer.write
            _permalink =AcosOpenApiHelper::PermalinkGenerator.create(_path, @swaggerfile)
            _menuItem = AcosOpenApiHelper::MenuItem.new(_path, _permalink)
            menu.add(_menuItem)
            cnt = cnt + 1

        end
        puts "Done generating %s pages..." % cnt
        puts "Writing menu"
        menu.write("%s/_data/sidebars" % @basePath, sidebar, docTitle)
    end

end

class AcosOpenApiHelper::SidebarMenu 
    @@entries = Array.new
    #attr_accessor :title, :url

    def self.all_entries
            @@entries
    end

    def add(entry)
        @@entries.push(entry)
    end


    def initialize()
        # @title = title
        # @url = url
        #@@entries << self
    end

    def write (output_path, name, menuTitle)
        _standardLines = [
            "# This is your sidebar TOC. The sidebar code loops through sections here and provides the appropriate formatting.",
            "entries:",
            "- title: sidebar",
            "  # product: Documentation",
            "  # version: 1.0",
            "  folders:",
            "  - title: %s" % menuTitle,
            "    output: web",
            "    type: frontmatter",
            "    folderitems: "
        ]
        puts "Writing menu with length:  %s" % @@entries.length
        @@entries.each do | item | 
                puts "Entry: %s, url: %s" % [item.title, item.url]
                _standardLines << "    - title: %s" % item.title
                _standardLines << "      url: /%s.html" % item.url
                _standardLines << "      output: web, pdf"
        end

        _standardLines << "    - title: %s" % "Models"
        _standardLines << "      url: /%s.html" % "userapi_components"
        _standardLines << "      output: web, pdf"
        # File.open("%s/%s/%s/%s.%s" % [@basePath, "pages", "swagger", @permalink, "md"], "w+") do |f|
        #     f.puts(@lines)
        #   end
        puts "Writing menu file for %s at %s" % [name, output_path]
        File.open("%s/%s.%s" % [output_path, name, "yml"], "w+") do | f |
            f.puts(_standardLines)
        end
    end
    
end

class AcosOpenApiHelper::MenuItem
    def initialize(title, url) 
        @title = title
        @url = url
    end

    def title
        @title
    end
    def url
        @url        
    end
end

class AcosOpenApiHelper::PermalinkGenerator
    def self.create(path, swaggerfile)
        @swaggerfileBase = File.basename(swaggerfile, ".*")
        @permalinkBase = "%s_%s" % [@swaggerfileBase, path]
        @permalink = @permalinkBase.gsub(/\s+|{|}|\//, "_").downcase
        return @permalink
    end

    def permalink
        @permalink
    end

end

class AcosOpenApiHelper::PageCreator
    def initialize(path, basePath, output_path, swaggerfile, sidebar)
        puts "Initialize intput %s, %s, %s, %s" % [path, output_path, swaggerfile, sidebar]
        @path = path
        @output_path = output_path
        @swaggerfile = swaggerfile
        @sidebar = sidebar
        @basePath = basePath
        @swaggerfileBase = File.basename(@swaggerfile, ".*")
        @permalink = AcosOpenApiHelper::PermalinkGenerator.create(path, @swaggerfile)
        @lines = [
            "---",
            "title: User API %s" % path,
            "keywords: json, openapi",
            "# summary: test med json fil",
            "sidebar: %s" % @sidebar,
            "permalink: %s.html" % @permalink,
            "folder: swagger",
            "toc: false",
            "swaggerfile: %s" % @swaggerfileBase,
            "swaggerpath: paths",
            "swaggerkey: %s" % @path,
            "---",
            "{\% include swagger_json/get_path.md \%}"
        ]
    end

    def write
        File.open("%s/%s/%s/%s.%s" % [@basePath, "pages", "swagger", @permalink, "md"], "w+") do |f|
            f.puts(@lines)
          end
    end
end

