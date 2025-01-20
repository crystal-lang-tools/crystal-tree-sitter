# crystal-tree-sitter

Crystal bindings for the [tree-sitter](https://github.com/tree-sitter/tree-sitter) API.

It works by reading the tree-sitter CLI configuration file to locate where the parsers can be found, then it loads the
parsers shared objects at runtime when needed. So any parser available on tree-sitter-cli must be available on Crystal.

This is not to be confused with [crystal-lang-tools/tree-sitter-crystal](https://github.com/crystal-lang-tools/tree-sitter-crystal),
which is a tree sitter parser for parsing Crystal lang.

## Installation

1. Add the dependency to your `shard.yml`:

   ```yaml
   dependencies:
     tree_sitter:
       github: crystal-lang-tools/crystal-tree-sitter
   ```

2. Run `shards install`

## Usage

API still not stable at all and subject to change. Meanwhile look at the spec tests to guess hwo to use it 😁️.

The code used in the [Using Parsers](https://tree-sitter.github.io/tree-sitter/using-parsers) tree-sitter tutorial
was ported as a spec test at [spec/tree_sitter_spec.cr](spec/tree_sitter_spec.cr), the API documentation is being
ported as well, not yet on github-pages, but run `crystal doc` and have fun.

```crystal
require "tree_sitter"

parser = TreeSitter::Parser.new("crystal")

source = <<-CRYSTAL
class Name
end
CRYSTAL

tree = parser.parse nil, source

query = TreeSitter::Query.new(parser.language, <<-SCM)
(class_def) @class

(constant) @constant
SCM

cursor = TreeSitter::QueryCursor.new(query)
cursor.exec(tree.root_node)

cursor.each_capture do |capture|
  p capture
end
```

## Contributing

1. Fork it (<https://github.com/crystal-lang-tools/crystal-tree-sitter/fork>)
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

## Contributors

- [Hugo Parente Lima](https://github.com/hugopl) - creator
- [Margret Riegert](https://github.com/nobodywasishere) - maintainer
