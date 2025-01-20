require "json"

module TreeSitter
  class Config
    include JSON::Serializable

    @[JSON::Field(key: "parser-directories")]
    property parser_directories : Array(Path)

    @@current : Config?

    def self.current : Config
      @@current ||= load_config
    end

    def self.parser_directories
      current.parser_directories
    end

    private def self.load_config : Config
      path : Path = begin
        {% if flag?(:darwin) %}
          ENV["XDG_CONFIG_HOME"]?.try { |f| Path.new(f) } || Path.home.join("Library", "Application Support")
        {% else %}
          ENV["XDG_CONFIG_HOME"]?.try { |f| Path.new(f) } || Path.home.join(".config")
        {% end %}
      end

      File.open(path.join("tree-sitter", "config.json")) do |fp|
        Config.from_json(fp)
      end
    end
  end
end
