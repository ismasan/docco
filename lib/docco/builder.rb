# frozen_string_literal: true

module Docco
  class Builder
    class SectionBuilder
      attr_reader :root, :nodes, :info, :path, :to_path, :sections

      def initialize(root:, node:, path:, children:, info:)
        @root = root
        @node = node
        @path = path
        @nodes = children
        @sections = @nodes.filter(&:section?)
        @info = info
        @path = [*path, node.id]
        @to_path = @path.join('/')
      end

      def id = @node.id
      def level = @node.level
      def title_html = @node.title_html
      def title = @node.title
      def to_html = @node.to_html
      def section? = @node.section?

      def build(*args)
        case args
        in [template]
          root.link self, template, to_path
        in [String => path, template]
          root.link self, template, path
        end
      end
    end

    attr_reader :nodes, :sections, :info, :root, :pages, :path, :to_path

    def initialize(nodes:, info:, root: self)
      @to_path = ''
      @path = [@to_path].freeze
      @nodes = nodes.map do |n|
        wrap_node(n, @path)
      end
      @sections = @nodes.filter(&:section?)
      @info = info
      @root = root
      @pages = {}
    end

    def root = self
    def to_html = @nodes.reduce(+'') { |str, n| str << n.to_html }

    def link(node, template, path)
      return path if @pages.key?(path)

      @pages[path] = true
      content = template.(node)
      @pages[path] = content
      path
    end

    def visit(theme)
      link self, theme, to_path
    end

    def build(*args)
      case args
      in [template]
        link self, template, to_path
      in [String => path, template]
        link self, template, path
      end
    end

    private

    # def initialize(root:, node:, parent:, children:, info:)
    def wrap_node(node, parent_path)
      return node unless node.section?

      children = node.nodes.map { |n| wrap_node(n, [*parent_path, node.id]) }
      SectionBuilder.new(root: self, node:, path: parent_path, children:, info:)
    end
  end
end
