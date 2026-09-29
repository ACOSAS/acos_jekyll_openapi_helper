require 'json'

class AcosOpenApiHelper
    def self.generate_pages(json_file, basePath, output_path)

        puts "Loading json file: %s" % [json_file]
        fileHelper = JsonFileHelper.new(json_file)
        fileHelper.load

        engine = PageEngine.new(fileHelper.json_data, basePath, output_path, json_file)
        engine.generate
    end

    def self.generate_pages_from_data(datafolder, basePath, output_path, only_files = [])
        json_files = Dir["%s/*.json" % datafolder]
        wanted = Array(only_files).map { |name| File.basename(name.to_s.strip) }.reject(&:empty?)
        unless wanted.empty?
            json_files = json_files.select { |jf| wanted.include?(File.basename(jf)) }
            missing = wanted - json_files.map { |jf| File.basename(jf) }
            unless missing.empty?
                raise "No swagger JSON matched: #{missing.join(', ')} in #{datafolder}"
            end
        end
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
        @swaggerfile = swaggerfile
        @basePath = basePath
    end        

    def generate
        puts "Generating pages..."
        cnt = 0
        puts "Open API version %s in .json file" % (@data.key?("openapi") ? @data['openapi'] : @data['swagger'])
        docTitle = (@data["info"]["title"])    
        _components = @data.key?("components")  ? "components" :"definitions"
        docFile = docTitle.gsub(/\+|\s+|{|}|\//, "_").downcase
        puts "Document title : %s" % docTitle
        sidebar =  "%s_sidebar" % docFile

        @data['paths'].each do |path|
            _path = path[0]
            writer =  AcosOpenApiHelper::PageCreator.new(_path, @basePath, @output_path, @swaggerfile, sidebar, docFile, _components)
            writer.write
            cnt = cnt + 1
        end
        AcosOpenApiHelper::PageCreator.createComponents(@basePath, docTitle, sidebar, @swaggerfile, docFile, _components)
        cnt = cnt + 1

        puts "Done generating %s pages..." % cnt
        puts "Sidebar is owned by overlay compose; gem does not write sidebar YAML."
    end
end

class AcosOpenApiHelper::PermalinkGenerator
    def self.create(path, swaggerfile)
        @swaggerfileBase = File.basename(swaggerfile, ".*")
        @permalinkBase = "%s_%s" % [@swaggerfileBase, path]
        @permalink = @permalinkBase.gsub(/\+|\s+|{|}|\//, "_").downcase
        unless @permalink =~ /\A[a-z0-9_-]+\z/
            raise "Unsafe permalink: #{@permalink}"
        end
        return @permalink
    end

    def permalink
        @permalink
    end

end

class AcosOpenApiHelper::FileNameGenerator
    def self.create(path, docFile)
        @docFileBase = "%s_%s" % [docFile, path]
        @docFileName = @docFileBase.gsub(/\+|\s+|{|}|\//, "_").downcase
        unless @docFileName =~ /\A[a-z0-9_-]+\z/
            raise "Unsafe generated filename: #{@docFileName}"
        end
        return @docFileName
    end

    def fileName
        @docFileName
    end
end

class AcosOpenApiHelper::PageCreator
    def initialize(path, basePath, output_path, swaggerfile, sidebar, docFile, component)
        @path = path
        @output_path = output_path
        @swaggerfile = swaggerfile
        @sidebar = sidebar
        @docFile = AcosOpenApiHelper::FileNameGenerator.create(@path, docFile)
        @basePath = basePath
        @swaggerfileBase = File.basename(@swaggerfile, ".*")
        @permalink = AcosOpenApiHelper::PermalinkGenerator.create(path, @swaggerfile)
        @lines = [
            "---",
            "# THIS PAGE IS GENERATED. ANY CHANGES TO PAGE WILL POTENTIALLY BE OVERWRITTEN.",
            "title: %s" % path,
            "keywords: json, openapi",
            "# summary: test med json fil",
            " #sidebars: ",
            " # - name: %s" % @sidebar,
            "permalink: %s.html" % @permalink,
            "folder: swagger",
            "toc: false",
            "swaggerfile: %s" % @swaggerfileBase,
            "swaggerpath: paths",
            "swaggerkey: %s" % @path,
            "swagger_components: %s" % component, 
            "components_file: %s" % docFile,
            "---",
            "{\% include swagger_json/get_path.md \%}",
            "{\% include swagger_json/overlay_slot.md slot=\"after_page\" \%}"
        ]
    end

    def write
        File.open("%s/%s/%s/%s.%s" % [@basePath, "pages", "swagger", @docFile, "md"], "w+") do |f|
            f.puts(@lines)
          end
    end

    def self.createComponents(basePath, title, sidebar, swaggerfile, docFile, componentsKey)
        swaggerfileName = File.basename(swaggerfile, ".*")
        unless docFile =~ /\A[a-z0-9_-]+\z/
            raise "Unsafe generated filename: #{docFile}"
        end
        contentLines = [
            "---",
            "title: %s Models" % title,
            "keyword: json, openapi, models, components",
            "sidebars:",
            " - name: %s" % sidebar,
            "folder: swagger",
            "toc: false",
            "swaggerfile: %s" % swaggerfileName,
            "swaggerkey: %s" % componentsKey,
            "permalink: %s_components.html" % docFile,
            "link: %s_components.html" % docFile,
            "---",
            "{% include swagger_json/get_components.md attribute='page.swaggerkey' %}",
            "",
            "{% include links.html %}",
        ]
        AcosOpenApiHelper::PageCreator.writeFile("%s/pages/swagger/%s_components.md" % [basePath, docFile], contentLines)
    end

    def self.writeFile(fullPath, contentLines )
        File.open("%s" % fullPath, "w+") do | f | 
            f.puts(contentLines)
        end
    end
end
