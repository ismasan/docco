# Docco

Docco is a Ruby gem that transforms your gem's README.md into a static HTML documentation website. It's designed to be simple, fast, and easy to integrate into your Ruby gem's workflow.

<img width="1071" height="1031" alt="CleanShot 2025-10-13 at 19 31 03" src="https://github.com/user-attachments/assets/db76935c-b0f7-4c14-adca-34366e6de4ad" />

## Features

- Converts GitHub-flavored Markdown to beautiful HTML documentation
- Automatic navigation sidebar generated from your README headings
- Syntax highlighting for code blocks (using highlight.js)
- Responsive design that works on all devices
- Active section highlighting as you scroll
- GitHub link integration from your gemspec
- GitHub Actions integration for automatic deployment to GitHub Pages
- Zero configuration required - works out of the box
- An ERB-based theming system that can also render multi-page websites, with a page per README section

## Installation

Add Docco to your gem's Gemfile:

```ruby
group :development do
  gem 'docco', github: 'ismasan/docco'
end
```

Or install it directly:

```bash
gem install docco
```

## Usage

### Basic Setup

Add the following to your gem's `Rakefile`:

```ruby
require 'docco/tasks'
```

That's it! Now you can generate documentation with:

```bash
bundle exec rake docco:docs
```

This will:
1. Read your `README.md`
2. Extract metadata from your `.gemspec`
3. Generate a beautiful HTML website in the `docs/` directory
4. Copy the necessary CSS styles

### Programmatic Usage

You can also use Docco programmatically in your Ruby code:

```ruby
require 'docco'

# Basic usage - auto-detects gemspec
builder = Docco::DocsBuilder.new(
  readme_path: 'README.md',
  output_dir: 'docs'
)
builder.build

# With custom gemspec path
builder = Docco::DocsBuilder.new(
  readme_path: 'README.md',
  output_dir: 'public/docs',
  gemspec_path: 'my_gem.gemspec'
)
builder.build
```

### Available Rake Tasks

Docco provides three rake tasks:

#### Generate Documentation

```bash
# Default: uses README.md and outputs to docs/
bundle exec rake docco:docs

# With custom paths
bundle exec rake docco:docs[path/to/README.md,output/dir,my_gem.gemspec]
```

#### Copy Styles

If you want to customize the styles, first copy the default stylesheet:

```bash
# Copies to docs/styles.css (default)
bundle exec rake docco:css

# Copy to custom directory
bundle exec rake docco:css[custom/path]
```

Then you can edit `docs/styles.css` to customize the appearance.

#### Generate GitHub Action

Automatically create a GitHub Action that builds and deploys your documentation to GitHub Pages:

```bash
bundle exec rake docco:gh
```

This creates `.github/workflows/deploy-docs.yml` with a pre-configured workflow that:
- Runs on push to main branch
- Builds your documentation
- Deploys to GitHub Pages

### GitHub Actions Integration

After running `rake docco:gh`, you'll have a GitHub Action that automatically deploys documentation. To complete the setup:

1. Go to your GitHub repository settings
2. Navigate to Pages section
3. Set source to "GitHub Actions"

Now every push to main will automatically rebuild and deploy your docs!

Example workflow (created by `docco:gh`):

```yaml
name: Deploy Documentation

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    permissions:
      contents: read
      pages: write
      id-token: write
    steps:
      - uses: actions/checkout@v3
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.2'
      - run: bundle install
      - run: bundle exec rake docco:docs
      - uses: actions/upload-pages-artifact@v1
        with:
          path: docs
      - uses: actions/deploy-pages@v1
```

## How It Works

Docco analyzes your README.md structure and creates a documentation website with:

1. **Navigation Sidebar**: Generated from level 2 and 3 headings (`##` and `###`) in your README
2. **Main Content**: Your entire README rendered as HTML
3. **Page Header**: Uses your gem name and summary from the gemspec
4. **GitHub Link**: Automatically extracted from your gemspec's `source_code_uri` or homepage

### README Structure Requirements

For best results, structure your README like this:

```markdown
# Gem Name

Brief description of your gem.

## Installation

Installation instructions...

## Usage

### Basic Usage

Example code...

### Advanced Usage

More examples...

## Configuration

Configuration options...

## Contributing

Contributing guidelines...
```

- The first `#` heading becomes the page title
- Level 2 headings (`##`) become main navigation items
- Level 3 headings (`###`) become sub-navigation items

## Customization

### Custom Styles

Copy the default styles and customize them:

```bash
bundle exec rake docco:css
```

Then edit `docs/styles.css` to match your branding. The CSS uses CSS custom properties (variables) for easy theming:

```css
:root {
  --primary-color: #007bff;
  --bg-color: #ffffff;
  --text-color: #333333;
  /* ... and many more */
}
```

### Gemspec Metadata

Docco extracts information from your gemspec. Make sure these fields are set:

```ruby
Gem::Specification.new do |spec|
  spec.name = "my_gem"
  spec.summary = "A short description"
  spec.description = "A longer description"
  spec.homepage = "https://github.com/username/my_gem"

  # For the GitHub link, set source_code_uri
  spec.metadata["source_code_uri"] = "https://github.com/username/my_gem"
end
```

## Themes

The default theme renders your entire README as a single page, but that's just one theme. Docco's templating system can also produce **multi-page websites**, where any section of your README becomes its own page with its own URL.

### How Theming Works

Three pieces cooperate:

- **`Docco.parse`** turns Markdown into a tree of *sections* (headings, nested by level) and *content nodes* (everything else).
- **`Docco::Builder`** walks that tree with a theme and collects the result into a `Hash<path, content>` — the whole website in memory.
- **`Docco::Writer`** (via `Docco.write`) writes that hash to disk. Paths without a file extension get `index.html` appended, so `/usage/basics` becomes `docs/usage/basics/index.html`.

A theme is a class that inherits from `Docco::Theme` and responds to `.call(node)`. Rendering starts at the root node, and templates create additional pages as they go.

### Defining Templates

`Docco::Theme.define` compiles an ERB string into a template. It also accepts anything that responds to `#read`, such as a `Pathname`, which is handy for keeping templates (and CSS) in separate files:

```ruby
require 'docco/theme'

class MyTheme < Docco::Theme
  # From a string
  Layout = define <<~HTML
    <html>
      <head><title><%= slots[:doc_title] || 'Home' %></title></head>
      <body><%= slots[:main] %></body>
    </html>
  HTML

  # From a file on disk
  Styles = define(Pathname.new(File.join(__dir__, 'styles.css')))
end
```

Calling `#define` on an existing template produces a **new** template that fills that layout's named **slots**. Pass a string to fill just the `:main` slot, or a block to fill several:

```ruby
# Fills the :main slot
HomeTemplate = Layout.define <<~HTML
  <h1><%= page.root.info.name %></h1>
  <p><%= page.root.info.summary %></p>
HTML

# Fills multiple slots
PageTemplate = Layout.define do |tpl|
  tpl.slot :doc_title, '<%= page.title %>'
  tpl.slot :main, <<~HTML
    <h1><%= page.title %></h1>
    <% page.nodes.each do |node| %>
      <%= node.to_html %>
    <% end %>
  HTML
end
```

Slots are rendered first, then the layout, so `slots[:main]` in the layout holds already-rendered HTML.

### Creating Pages With `build`

`build` is what makes multi-page themes possible. Inside a template, calling `build` on a node:

1. renders the given template for that node,
2. registers the result in the site under that node's path,
3. and **returns the path** — so it goes straight into an `href`.

```erb
<a href="<%= section.build(MyTheme::PageTemplate) %>"><%= section.title %></a>
```

The path is derived from the node's position in the README tree (`/my-gem/usage/basic-setup`). Pass an explicit path as the first argument when you want to control it — this is also how static assets are emitted:

```erb
<link rel="stylesheet" href="<%= page.build('styles.css', MyTheme::Styles) %>">
```

Pages are memoized by path, so templates can link to each other freely. A sidebar that links to every page, rendered on every page, terminates instead of recursing forever.

Note that stylesheets are themselves ERB templates, so they can interpolate values too.

### Template API

Each template is evaluated with two locals: `page` (the node being rendered, also available as `node`) and `slots`.

Section nodes respond to:

| Method | Description |
| --- | --- |
| `title` | The heading's contents as inline HTML (e.g. `This is the <code>title</code>`) |
| `title_html` | The full rendered heading element (`<h2 id="usage">Usage</h2>`) |
| `id` | Kramdown's auto-generated anchor id, de-duplicated across the document |
| `level` | Heading level (1-6) |
| `nodes` | Child nodes, both sections and content |
| `sections` | Child nodes that are sections |
| `section?` | `true` for sections, `false` for content nodes |
| `to_html` | The section and all its descendants rendered as HTML |
| `to_path` | This node's path within the site |
| `build(template)` / `build(path, template)` | Render a sub-page and return its path |
| `root` | The `Builder`, i.e. the site root |
| `info` | Gem metadata |

Content nodes (paragraphs, code blocks, lists, etc.) are minimal: `to_html` and `section?`.

The root node passed to `.call` is the `Builder` itself. It has `nodes`, `sections`, `to_html`, `build`, `info` and `root` (which returns itself), but no `title` or `id` — pull page titles from `page.root.info` at that level.

`info` is a `Docco::Info` with `name`, `summary`, `description` and `repo_url`, read from your gemspec.

### A Multi-Page Theme

This theme puts every `##` and `###` section on its own page, with a shared navigation menu:

```ruby
require 'docco/theme'

class MyTheme < Docco::Theme
  Styles = define(Pathname.new(File.join(__dir__, 'styles.css')))

  Layout = define <<~HTML
    <!DOCTYPE html>
    <html>
      <head>
        <link rel="stylesheet" href="<%= page.build('styles.css', MyTheme::Styles) %>">
        <title><%= slots[:doc_title] || 'Home' %> / <%= page.root.info.name %></title>
      </head>
      <body>
        <nav>
          <a href="/">Home</a>
          <% page.root.sections.each do |top| %>
            <ul>
              <% top.sections.each do |section| %>
                <li>
                  <a href="<%= section.build(MyTheme::PageTemplate) %>"><%= section.title %></a>
                </li>
              <% end %>
            </ul>
          <% end %>
        </nav>
        <main><%= slots[:main] %></main>
      </body>
    </html>
  HTML

  PageTemplate = Layout.define do |tpl|
    tpl.slot :doc_title, '<%= page.title %>'
    tpl.slot :main, <<~HTML
      <h1><%= page.title %></h1>
      <% page.nodes.each do |node| %>
        <% if node.section? %>
          <h2><a href="<%= node.build(MyTheme::PageTemplate) %>"><%= node.title %></a></h2>
        <% else %>
          <%= node.to_html %>
        <% end %>
      <% end %>
    HTML
  end

  HomeTemplate = Layout.define <<~HTML
    <h1><%= page.root.info.name %></h1>
    <p><%= page.root.info.summary %></p>
  HTML

  # Entry point. Rendering starts here, with the site root.
  def self.call(node) = HomeTemplate.call(node)
end
```

`PageTemplate` links to its own subsections using itself, so the site nests as deeply as your headings do.

### Rendering a Site With a Custom Theme

`rake docco:docs` and `Docco::DocsBuilder` always use `Docco::Themes::Default`. To use your own theme, drive `Builder` and `Writer` directly:

```ruby
require 'docco'
require_relative 'my_theme'

root = Docco.parse(File.read('README.md'))

info = Docco::Info.new(
  name: 'my_gem',
  summary: 'A short description',
  description: 'A longer description',
  repo_url: 'https://github.com/username/my_gem'
)

builder = Docco::Builder.new(nodes: root.nodes, info:)
builder.visit(MyTheme)

# builder.pages is now a Hash<path, content> holding the entire site:
#   { '' => '<html>...', 'styles.css' => 'body { ... }',
#     '/my-gem/usage' => '<html>...', ... }

Docco.write(builder.pages, output_dir: 'docs', overwrite: true)
```

`overwrite` defaults to `false`, which leaves existing files untouched — useful when you hand-edit a generated stylesheet and don't want it clobbered. Pass `overwrite: true` to regenerate everything.

Because `builder.pages` is a plain hash, writing to disk is optional. You can serve it straight from memory from a Rack app, or post-process it before writing.

### Extending the Default Theme

`Docco::Themes::Default` is built from the same primitives, and its templates are public constants (`Layout`, `Menu`, `Section`, `HomePageTemplate`, `Styles`). Reading [`lib/docco/themes/default.rb`](https://github.com/ismasan/docco/blob/main/lib/docco/themes/default.rb) is the quickest way to see a complete theme, and you can reuse individual templates from your own:

```erb
<%= Docco::Themes::Default::Menu.(page) %>
```

## Example Output

Check out Docco's own documentation (built with Docco, of course!):
[https://ismasan.github.io/docco](https://ismasan.github.io/docco)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

### Testing Your Changes

Generate documentation for Docco itself:

```bash
bundle exec rake docco:docs
```

Then open `docs/index.html` in your browser to see the results.

## Requirements

- Ruby >= 3.2.0
- A README.md file
- (Optional) A .gemspec file for metadata

## Dependencies

- `kramdown` - Markdown parsing
- `kramdown-parser-gfm` - GitHub-flavored Markdown support

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ismasan/docco.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Credits

Created by [Ismael Celis](https://ismaelcelis.com)
