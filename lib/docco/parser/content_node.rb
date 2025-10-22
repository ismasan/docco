# frozen_string_literal: true

module Docco
  class Parser
    class ContentNode
      def initialize(converter, node)
        @converter = converter
        @node = node
      end

      def inspect = %(<#{self.class}:#{@node.type} [#{@node.children}]>)
      def section? = false

      def to_html
        @to_html ||= @converter.convert(@node, 0)
      end
    end
  end
end
