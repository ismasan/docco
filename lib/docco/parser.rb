# frozen_string_literal: true

require 'kramdown'

module Docco
  class Parser
    # Subclasses Kramdown's HTML converter so we can capture each top-level
    # child's rendered HTML during a single top-down walk. Overriding only
    # convert_root lets Kramdown drive the recursion normally (so @stack,
    # @footnotes, @used_ids, etc. behave as designed); we just replace the
    # root-level concatenation step with a per-child capture into a hash
    # keyed by Kramdown element identity.
    class Renderer < Kramdown::Converter::Html
      attr_reader :per_element_html

      def initialize(root, options)
        super
        @per_element_html = {}
      end

      def convert_root(el, indent)
        @stack.push(el)
        indent += @indent
        el.children.each do |child|
          @per_element_html[child] = send(@dispatcher[child.type], child, indent)
        end
        @stack.pop
        ''
      end
    end

    def initialize(text, input: 'GFM')
      @text = text
      @input = input
    end

    def structure
      @structure ||= build
    end

    private

    def build
      doc = Kramdown::Document.new(@text, input: @input, auto_ids: true)
      renderer = Renderer.send(:new, doc.root, doc.options)
      renderer.convert(doc.root)

      root = Root.new
      last_section = root
      levels = Hash.new { |h, k| h[k] = [] }
      levels[root.level] << root

      doc.root.children.each do |child|
        html = renderer.per_element_html.fetch(child)
        if child.type == :header
          section = Section.new(node: child, html: html)
          levels[section.level] << section
          levels[section.level - 1].last&.<<(section)
          last_section = section
        else
          last_section.add_content(child, html)
        end
      end

      root
    end
  end
end

require 'docco/parser/section'
require 'docco/parser/root'
require 'docco/parser/content_node'
