# frozen_string_literal: true

module Docco
  class Parser
    class Root
      attr_reader :nodes, :level

      def initialize(converter)
        @converter = converter
        @nodes = []
        @level = 0
      end

      def inspect = %(<#{self.class} [#{@nodes.size} nodes]>)

      def <<(section)
        @nodes << section
      end

      def add_content(node)
        @nodes << ContentNode.new(@converter, node)
      end

      def to_html
        @to_html ||= @nodes.reduce(+'') do |str, node|
          str << node.to_html << "\n"
        end
      end
    end
  end
end
