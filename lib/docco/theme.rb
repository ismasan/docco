# frozen_string_literal: true

require 'erb'

module Docco
  # Theme is a templating system that uses ERB templates with named slots.
  # It allows you to define a base template and then create specialized
  # versions by filling in slots with different content.
  class Theme
    class Static
      def initialize(path, content)
        @path = path
        @content = content.respond_to?(:read) ? content : StringIO.new(content)
      end
    end

    class Slots
      def initialize
        @slots = {}
      end

      def slot(name, str)
        @slots[name] = ERB.new(str)
      end

      def to_h = @slots
    end

    # Creates a new Theme from an ERB template string.
    #
    # @param str [String, #read] ERB template string that defines the layout
    # @return [Theme] a new Theme instance with the compiled template
    #
    # @example Create a basic layout theme
    #   Layout = Docco::Theme.define <<~HTML
    #     <html>
    #       <head>
    #         <title><%= slots[:doc_title] || 'Home' %></title>
    #       </head>
    #       <body>
    #         <%= slots[:main] %>
    #       </body>
    #     </html>
    #   HTML
    #
    # Template can also be a #read() => String interface
    # for example a File or Pathname to read templates from disk
    # @example
    #   Page = Docco::Theme.define(Pathname.new('./theme/page.erb'))
    def self.define(str)
      str = str.read if str.respond_to?(:read)
      tmpl = ERB.new(str)
      new(tmpl)
    end

    def self.call(node)
      raise NotImplementedError, "define #{self}.call(node) to delegate .call(node) to the right root template (usually the homepage)"
    end

    # Initializes a new Theme instance.
    #
    # @param tpl [ERB] compiled ERB template
    # @param slots [Hash<Symbol, ERB>] hash of named slots with their ERB templates
    # @return [Theme] a new Theme instance
    #
    # @example Create a theme with template and slots
    #   tpl = ERB.new("<div><%= slots[:content] %></div>")
    #   slots = { content: ERB.new("<p>Hello</p>") }
    #   theme = Docco::Theme.new(tpl, slots: slots)
    def initialize(tpl, slots: {})
      @tpl = tpl
      @slots = slots
    end

    # Creates a new theme by defining slots for the template.
    # Can accept either a string (which becomes the :main slot) or a block
    # that yields a Slots object for defining multiple slots.
    #
    # @param str [String, nil] optional string to use as the :main slot
    # @yield [Slots] yields a Slots object for defining named slots
    # @return [Theme] a new Theme instance with the defined slots
    #
    # @example Define a theme with a string for the main slot
    #   HomeTemplate = Layout.define <<~HTML
    #     <h1>Home page</h1>
    #     <% page.sections.each do |s| %>
    #       <%= s.title_html %>
    #     <% end %>
    #   HTML
    #
    # @example Define a theme with multiple slots using a block
    #   PageTemplate = Layout.define do |tpl|
    #     tpl.slot :doc_title, '<%= page.title %>'
    #     tpl.slot :main, <<~HTML
    #       <h1><%= page.title %></h1>
    #       <% page.nodes.each do |n| %>
    #         <%= n.to_html %>
    #       <% end %>
    #     HTML
    #   end
    def define(str = nil, &)
      slots = Slots.new
      if str
        slots.slot(:main, str)
      elsif block_given?
        yield slots
      end
      self.class.new(@tpl, slots: slots.to_h)
    end

    Context = Data.define(:node, :slots) do
      def page = node
      def get_binding = binding
    end

    # Renders the theme with the given node by evaluating all slot templates
    # and then the main template.
    #
    # @param node [Object] the node object to render (available as 'page' in templates)
    # @return [String] the rendered HTML output
    #
    # @example Render a theme with a node
    #   output = PageTemplate.call(node)
    #   # => "<html><head>...</head><body>...</body></html>"
    def call(node)
      ctx = Context.new(node:, slots: {})
      slots = @slots.transform_values do |tpl|
        tpl.result(ctx.get_binding)
      end
      ctx = Context.new(node:, slots:)
      @tpl.result(ctx.get_binding)
    end
  end
end
