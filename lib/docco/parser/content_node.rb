# frozen_string_literal: true

module Docco
  class Parser
    class ContentNode
      def initialize(node, html)
        @node = node
        @html = html
      end

      def inspect = %(<#{self.class}:#{@node.type} [#{@node.children}]>)
      def section? = false
      def to_html = @html
    end
  end
end
