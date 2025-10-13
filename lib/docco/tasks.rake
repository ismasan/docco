# frozen_string_literal: true

require 'docco'

namespace :docco do
  desc 'Copy default styles.css to host library docs'
  task :css, [:output_dir] do |t, args|
    output_dir = args[:output_dir] || 'docs'
    Docco::CopyStyles.(output_dir)
  end

  desc 'Generate a Github Action into .github/workflows'
  task :gh do
    Docco::CopyGHAction.()
  end

  desc "Build documentation website from README"
  task :docs, [:readme_path, :output_dir, :gemspec] do |t, args|
    readme_path = args[:readme_path] || 'README.md'
    output_dir = args[:output_dir] || 'docs'
    gemspec = args[:gemspec]

    builder = Docco::DocsBuilder.new(
      readme_path: readme_path,
      output_dir: output_dir,
      gemspec_path: gemspec
    )

    builder.build
  end
end
