# frozen_string_literal: true

module Docco
  class Parser
    class Section
      HEADING_EXP = /<\s*h([1-6])\b[^>]*>(.*?)<\/\s*h\1\s*>/im

      attr_reader :id, :options, :nodes

      def initialize(converter:, node:)
        @converter = converter
        @node = node
        @id = node.attr['id']
        @options = node.options
        @nodes = []
      end

      def inspect = %(<#{self.class}:H#{level}##{id} [#{nodes.size} nodes]>)
      def section? = true

      def level = @options[:level]

      def <<(section)
        @nodes << section
      end

      def add_content(node)
        @nodes << ContentNode.new(@converter, node)
      end

      def title_html
        @to_html ||= @converter.convert(@node, 0)
      end

      def title
        @title ||= title_html.match(HEADING_EXP)[2]
      end

      def to_html
        @nodes.reduce(title_html) do |str, node|
          str << "\n" << node.to_html
        end
      end
    end
  end
end
