# frozen_string_literal: true

require 'kramdown'

module Docco
  class Parser
    def initialize(text, input: 'GFM')
      @text = text
      @input = input
    end

    def structure
      @structure ||= build
    end

    private
    # cc = Kramdown::Converter::Html.send(:new, doc.root, doc.options)
    # cc.convert doc.children[0], 1 # <= 1 is indent and it's needed
    def build
      doc = Kramdown::Document.new(@text, input: @input, auto_ids: true)
      converter = Kramdown::Converter::Html.send(:new, doc.root, doc.options)
      root = Root.new(converter)
      last_section = root
      levels = Hash.new { |h, k| h[k] = [] }
      levels[last_section.level] << last_section # root

      doc.root.children.each do |child|
        if child.type == :header
          section = Section.new(converter:, node: child)
          levels[section.level] << section
          if (parent = levels[section.level - 1].last)
            parent << section
          end
          last_section = section
        else # not a section. Content belonging to last section, or directly to root
          last_section.add_content child
        end
      end

      root
    end
  end
end

require 'docco/parser/section'
require 'docco/parser/root'
require 'docco/parser/content_node'
