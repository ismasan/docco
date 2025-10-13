# frozen_string_literal: true

require_relative "lib/docco/version"

Gem::Specification.new do |spec|
  spec.name = "docco"
  spec.version = Docco::VERSION
  spec.authors = ["Ismael Celis"]
  spec.email = ["ismaelct@gmail.com"]

  spec.summary = "Builds static HTML documentation from a Ruby gem's README"
  spec.description = "Builds static HTML documentation from a Ruby gem's README"
  spec.homepage = "https://github.com/ismasan/docco"
  spec.required_ruby_version = ">= 3.2.0"
  spec.post_install_message = <<~MSG

    +----------------------------+
      Docco is now installed.
      Add the following in your library's Rakefile:

        require 'docco/tasks'

      Now you can run `bundle exec rake docco:docs` to generate HTML docs from your README.md and .gemspec

      You can also run `bundle exec rake docco:gh` to add a Github action to generate docs to Github Pages on deply.
    +-----------------------------+

  MSG

  spec.metadata["homepage_uri"] = spec.homepage
  # spec.metadata["source_code_uri"] = "TODO: Put your gem's public repo URL here."
  # spec.metadata["changelog_uri"] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  gemspec = File.basename(__FILE__)
  spec.files = Dir['lib/**/*']
  # spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
  #   ls.readlines("\x0", chomp: true).reject do |f|
  #     (f == gemspec) ||
  #       f.start_with?(*%w[bin/ Gemfile .gitignore .rspec spec/])
  #   end
  # end
  spec.bindir = "exe"
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  # Uncomment to register a new dependency of your gem
  spec.add_dependency 'kramdown'
  spec.add_dependency 'kramdown-parser-gfm'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
end
