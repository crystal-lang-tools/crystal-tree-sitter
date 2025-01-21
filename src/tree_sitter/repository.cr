require "colorize"
require "./config"
require "./language"

module TreeSitter
  class Repository
    @@language_paths : Hash(String, Path)?

    def self.language_paths : Hash(String, Path)
      @@language_paths ||= begin
        languages = Hash(String, Path).new
        Config.parser_directories.each do |dir|
          Dir[dir.join("*", "src", "grammar.json")].each do |grammar_path|
            languages[$2] = Path.new($1) if grammar_path =~ %r{(.*/tree\-sitter\-([\w\-_]+))/src/grammar.json\z}
          end
        end
        languages
      end
    end

    def self.preload_all
      language_paths.each { |name, path| load_language?(name, path) }
    end

    def self.language_names : Array(String)
      language_paths.keys
    end

    def self.load_language(name : String)
      load_language(name, language_paths[name])
    end

    def self.load_language(name : String, path : Path) : Language
      lang_path = language_paths[name]?
      raise Error.new("Unknown language: #{name}.") if lang_path.nil?

      ts_lang = load_shared_object(name, path)
      Language.new(name, ts_lang)
    end

    def self.load_language?(name : String, path : Path) : Language?
      load_language(name, path)
    rescue Error
      nil
    end

    def self.load_shared_object(language_name : String, language_path : Path) : LibTreeSitter::TSLanguage*
      file_extension = {% if flag?(:darwin) %}
                         "dylib"
                       {% else %}
                         "so"
                       {% end %}

      so_path = language_path.join("libtree-sitter-#{language_name}.#{file_extension}")

      raise Error.new("#{so_path} doesn't exists. Create it using tree-sitter CLI.") unless File.exists?(so_path)

      handle = LibC.dlopen(so_path.to_s, LibC::RTLD_LAZY | LibC::RTLD_LOCAL)
      raise Error.new("Can't load language #{language_name}. #{so_path} was not found.") if handle.null?

      ptr = LibC.dlsym(handle, "tree_sitter_#{language_name}")
      raise Error.new("Can't find symbol tree_sitter_#{language_name} at #{so_path}.") unless ptr

      Proc(LibTreeSitter::TSLanguage*).new(ptr, Pointer(Void).null).call
    end
  end
end
