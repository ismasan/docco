# frozen_string_literal: true

require 'docco/theme'

module Docco
  module Themes
    class Default < Theme
      Styles = define(Pathname.new(File.join(__dir__, 'default.css')))

      Layout = define <<~HTML
      <!DOCTYPE html>
      <html lang="en">
      <head>
          <meta charset="UTF-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
          <title>#{@gem_name} - #{@gem_summary}</title>
          <link rel="stylesheet" href="<%= page.build('styles.css', Docco::Themes::Default::Styles) %>">
          <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/styles/atom-one-dark.min.css">
      </head>
      <body>
          <nav class="top-menu">
              <div class="top-menu-content">
                  <div class="top-menu-brand">
                    <span class="brand-name"><%= page.root.info.name %></span>
                    <span class="brand-tagline"><%= page.root.info.description %></span>
                  </div>
                    <a href="<%= page.root.info.repo_url %>" target="_blank" class="github-link" aria-label="View on GitHub">
                      <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="currentColor">
                          <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z"/>
                      </svg>
                      <span>GitHub</span>
                  </a>
              </div>
          </nav>
          <div class="container">
              <nav class="sidebar">
                  <div class="logo">
                    <h2><%= page.root.info.name %></h2>
                    <p class="tagline"><%= page.root.info.description %></p>
                  </div>
                  <%= Docco::Themes::Default::Menu.(page) %>
              </nav>

              <main class="content">
                  <header class="page-header">
                      <h1><%= page.root.info.name %></h1>
                      <p class="subtitle"><%= page.root.info.summary %></p>
                  </header>

                  <%= slots[:main] %>
              </main>
          </div>
          <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/highlight.min.js"></script>
          <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/11.9.0/languages/ruby.min.js"></script>
          <script>hljs.highlightAll();</script>
          <script>
              // Active section highlighting
              const observerOptions = {
                  root: null,
                  rootMargin: '-20% 0px -60% 0px',
                  threshold: 0
              };

              const sections = document.querySelectorAll('section, article[id]');
              const navLinks = document.querySelectorAll('.nav-menu a');

              // Create a map of href to link elements
              const linkMap = new Map();
              navLinks.forEach(link => {
                  const href = link.getAttribute('href');
                  if (href && href.startsWith('#')) {
                      linkMap.set(href, link);
                  }
              });

              const observer = new IntersectionObserver((entries) => {
                  entries.forEach(entry => {
                      if (entry.isIntersecting) {
                          const id = entry.target.getAttribute('id');
                          const activeLink = linkMap.get(`#${id}`);

                          if (activeLink) {
                              // Remove active class from all links
                              navLinks.forEach(link => link.classList.remove('active'));
                              // Add active class to current link
                              activeLink.classList.add('active');

                              // Update URL hash without scrolling
                              if (history.replaceState) {
                                  history.replaceState(null, null, `#${id}`);
                              } else {
                                  window.location.hash = id;
                              }
                          }
                      }
                  });
              }, observerOptions);

              // Observe all sections
              sections.forEach(section => {
                  if (section.id) {
                      observer.observe(section);
                  }
              });
          </script>
      </body>
      </html>
      HTML

      Menu = Theme.define <<~HTML
      <ul class="nav-menu">
        <% page.sections.each do |section| %>
          <% section.sections.each do |section| %>
            <li>
              <a href="#<%= section.id %>"><%= section.title %></a>
              <% if section.sections.any? %>
                <ul>
                  <% section.sections.each do |section| %>
                    <li class="nav-submenu">
                      <a href="#<%= section.id %>"><%= section.title %></a>
                    </li>
                  <% end %>
                </ul>
              <% end %>
            </li>
          <% end %>
        <% end %>
      </ul>
      HTML

      Section = Theme.define <<~HTML
      <section id="<%= page.id %>" class="section">
        <h2><%= page.title %></h2>
        <% page.nodes.each do |node| %> 
          <% if node.section? %> 
            <article id="<%= node.id %>" class="subsection">
              <h3><%= node.title %></h3>
              <% node.nodes.each do |n| %>
                <%= n.to_html %>
              <% end %>
            </article>
          <% else %>
            <%= node.to_html %>
          <% end %>
        <% end %>
      </section>
      HTML

      HomePageTemplate = Layout.define <<~HTML
      <% page.nodes.each do |node| %> 
        <% if node.section? %> 
          <% node.nodes.each do |node| %> 
            <% if node.section? %> 
              <%= Docco::Themes::Default::Section.(node) %>
            <% else %>
              <%= node.to_html %>
            <% end %>
          <% end %>
        <% else %>
          <%= node.to_html %>
        <% end %>
      <% end %>
      HTML

      def self.call(node)
        HomePageTemplate.call(node)
      end
    end
  end
end
