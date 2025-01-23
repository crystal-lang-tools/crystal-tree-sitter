require "./spec_helper"

describe TreeSitter::Predicate do
  it "supports `#match?`" do
    parser = TreeSitter::Parser.new("json")
    source = <<-JSON
      {
        "hello": 2
        "goodnight": [
          "moon", "sky", "earth", 1
        ]
      }
      JSON

    tree = parser.parse nil, source

    query = TreeSitter::Query.new(parser.language, <<-SCM)
      ((number) @test
        (#match? @test "1"))
      SCM

    cursor = TreeSitter::QueryCursor.new(query)
    cursor.exec(tree.root_node)

    idx = 0
    cursor.each_capture do |capture|
      if idx == 0
        capture.text(source).should eq("2")
        TreeSitter::Predicate.resolve(query, capture, source).should eq(false)
      elsif idx == 1
        capture.text(source).should eq("1")
        TreeSitter::Predicate.resolve(query, capture, source).should eq(true)
      else
        raise "shouldn't be here"
      end
    ensure
      idx += 1
    end
  end
end
