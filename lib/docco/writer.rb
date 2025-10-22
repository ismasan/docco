# frozen_string_literal: true

require 'pathname'

module Docco
  # Writes documents to the file system.
  #
  # The Writer class handles writing page content to disk with proper directory creation,
  # path handling, and optional overwrite protection. It transforms logical page paths
  # into actual file system paths, appending 'index.html' to directory paths as needed.
  #
  # @example Writing pages to output directory
  #   pages = {
  #     '' => '<html>Home</html>',
  #     '/docs' => '<html>Docs</html>',
  #     '/styles.css' => 'body { color: red; }'
  #   }
  #   writer = Docco::Writer.new(pages, output_dir: 'output', overwrite: false)
  #   report = writer.write
  #
  # The above example writes the following files:
  #   output/index.html
  #   output/docs/index.html
  #   output/styles.css
  #
  class Writer
    # Initializes a new Writer instance with pages and output configuration.
    #
    # Transforms page paths by:
    # - Converting relative paths to absolute paths within output_dir
    # - Appending 'index.html' to paths without file extensions (directory paths)
    # - Creating Pathname objects for each path
    #
    # @param pages [Hash<String, String>] Hash of page paths to content strings.
    #   Keys are logical page paths (e.g., '', '/docs', '/assets/style.css').
    #   Values are the content to write to those files.
    #
    # @param output_dir [String] The root directory where pages will be written.
    #   All page paths will be relative to this directory.
    #
    # @param overwrite [Boolean] Whether to overwrite existing files.
    #   If false (default), existing files will not be modified.
    #   If true, existing files will be overwritten with new content.
    #
    # @example
    #   writer = Docco::Writer.new(
    #     { '' => 'Home', '/docs' => 'Documentation' },
    #     output_dir: 'output',
    #     overwrite: false
    #   )
    def initialize(pages, output_dir:, overwrite: false)
      @pages = pages.transform_keys do |path|
        path = Pathname.new(File.join(output_dir, path))
        path += 'index.html' if path.extname.empty?
        path
      end

      @overwrite = overwrite
    end

    def write
      @pages.each.with_object({}) do |(path, content), memo|
        memo[path.to_s] = write_page(path, content)
      end
    end

    private def write_page(path, content)
      return false if !@overwrite && path.exist?

      path.dirname.mkpath
      path.write(content)
    end
  end
end
