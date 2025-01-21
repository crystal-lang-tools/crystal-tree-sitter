module TreeSitter
  PREDICATES = {
    "match?" => MatchPredicate,
  }

  abstract class Predicate
    @query : TreeSitter::Query
    @steps : Array(LibTreeSitter::TSQueryPredicateStep)

    def initialize(@query, @steps)
    end

    def self.resolve(
      query : TreeSitter::Query,
      capture : TreeSitter::Capture,
      source : String,
    ) : Bool
      unsafe_steps = LibTreeSitter.ts_query_predicates_for_pattern(
        query,
        capture.capture_index,
        out step_count
      )
      steps = Slice.new(unsafe_steps, step_count).to_a

      name_ptr = LibTreeSitter.ts_query_string_value_for_id(
        query.to_unsafe, steps[0].value_id, out name_len
      )

      name = String.new(name_ptr, name_len)

      !!PREDICATES[name]?.try(&.new(query, steps).call(capture, source))
    end
  end

  class MatchPredicate < Predicate
    def call(capture : TreeSitter::Capture, source : String) : Bool
      # Get the regex pattern from the third step (steps[2])
      pattern_ptr = LibTreeSitter.ts_query_string_value_for_id(
        @query.to_unsafe,
        @steps[2].value_id,
        out pattern_len
      )
      pattern = String.new(pattern_ptr, pattern_len)

      # Get the text from the captured node
      node_text = capture.text(source)

      # Match the captured text against the regex pattern
      Regex.new(pattern).matches?(node_text)
    end
  end
end
