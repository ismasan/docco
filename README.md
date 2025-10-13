# Docco

Docco is a Ruby gem that transforms your gem's README.md into a beautiful, responsive static HTML documentation website. It's designed to be simple, fast, and easy to integrate into your Ruby gem's workflow.

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

Created by [Ismael Celis](https://github.com/ismasan)
