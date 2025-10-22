# frozen_string_literal: true

require 'docco/theme'

class TestTheme < Docco::Theme
  Styles = define(Pathname.new(File.join(__dir__, 'test_theme.css')))

  Layout = define <<~HTML
  <html>
    <head>
      <link href="<%= page.build('styles.css', TestTheme::Styles) %>" />
      <title><%= slots[:doc_title] || 'Home' %> / <%= page.root.info.name %></title>
    </head>
    <body>
      <a href="/">Home</a>
      <% page.root.sections.each do |n| %>
      <ul>
        <% n.sections.each do |n| %>
          <li>
            <a href="<%= n.build(TestTheme::PageTemplate) %>"><%= n.title %></a>
            <% if n.sections.any? %>
            <ul>
              <% n.sections.each do |n| %>
              <li>
                <a href="<%= n.build(TestTheme::PageTemplate) %>"><%= n.title %></a>
              </li>
              <% end %>
            </ul>
            <% end %>
          </li>
        <% end %>
      </ul>
      <% end %>
      <div id="main">
        <%= slots[:main] %>
      </div>
    </body>
  </html>
  HTML

  PageTemplate = Layout.define do |tpl|
    tpl.slot :doc_title, '<%= page.title %>'
    tpl.slot :main, <<~HTML
    <h1><%= page.title %></h1>
    <% page.nodes.each do |n| %>
      <% if n.section? %>
      <h2><a href="<%= n.build(TestTheme::PageTemplate) %>"><%= n.title %></a></h2>
      <% else %>
        <%= n.to_html %>
      <% end %>
    <% end %>
    HTML
  end

  HomeTemplate = Layout.define <<~HTML
  <h1>Home page</h1>
  <% page.sections.each do |s| %>
  <%= s.title_html %>
  <% end %>
  HTML

  # Entry point to Builder visitor
  # Templates can call other templates
  # while linking to other pages, which will 
  # create a data structure Hash<URLPath, HTML>
  # with the entire website, which can then
  # be saved as files to disk, of directly 
  # served from memory.
  # @param [Builder::Section] the root section (homepage) for this site 
  def self.call(node)
    HomeTemplate.call(node)
  end
end

