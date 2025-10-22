# frozen_string_literal: true

require 'docco/theme'
require_relative './test_theme'

RSpec.describe Docco do
  let(:readme) do
    <<~MARKDOWN.strip
    Orphan text here

    # This is the `title`
    Some text   

    ## Section 1
    Text for section 1

    More text for section 1

    ```ruby
    uno = 1
    ```

    ### Subsection 1.A
    Text for subsection 1.A _with italics_.

    ### Subsection 1.B
    Text for subsection 1.B *with bold letters*.

    ## Section 2
    ### Subsection 2.A
    Text for subsection 2.A
    MARKDOWN
  end

  it "has a version number" do
    expect(Docco::VERSION).not_to be nil
  end

  describe '.parse' do
    it 'parses Mardown text into a structure' do
      tree = Docco.parse(readme)
      expect(tree.nodes.map(&:class)).to eq([
        Docco::Parser::ContentNode,
        Docco::Parser::ContentNode,
        Docco::Parser::Section
      ])
      expect(tree.nodes[0].to_html).to eq(%(<p>Orphan text here</p>\n))
      expect(tree.nodes[1].to_html).to eq(%(\n))
      expect(tree.nodes[2].title).to eq(%(This is the <code>title</code>))
      expect(tree.nodes[2].title_html).to eq(%(<h1 id="this-is-the-title">This is the <code>title</code></h1>\n))
      expect(tree.nodes[2].id).to eq(%(this-is-the-title))
      expect(tree.nodes[2].nodes.map(&:class)).to eq([
        Docco::Parser::ContentNode,
        Docco::Parser::ContentNode,
        Docco::Parser::Section,
        Docco::Parser::Section
      ])
      expect(tree.nodes[2].nodes[0].to_html).to eq(%(<p>Some text</p>\n))
      expect(tree.nodes[2].nodes[3].title).to eq(%(Section 2))
      expect(tree.nodes[2].nodes[3].nodes[0].title).to eq(%(Subsection 2.A))
      expect(tree.nodes[2].nodes[3].nodes[0].nodes[0].to_html).to eq(%(<p>Text for subsection 2.A</p>\n))
    end
  end

  specify '.build' do
    root = Docco.parse(readme)
    info = Docco::Info.new(name: 'docs', summary: 'summary', description: 'desc', repo_url: 'https://github.com/foo/bar')
    builder = Docco::Builder.new(nodes: root.nodes, info:)

    builder.visit(TestTheme)
    expect(builder.pages.keys).to match_array([
      '',
      'styles.css',
      "/this-is-the-title/section-1",
      "/this-is-the-title/section-1/subsection-1a",
      "/this-is-the-title/section-1/subsection-1b",
      "/this-is-the-title/section-2",
      "/this-is-the-title/section-2/subsection-2a"
    ])

    expect(builder.pages['']).to match(/<html>/)
    expect(builder.pages['']).to match(%r{<a href="/this-is-the-title/section-1">Section 1</a>})
    expect(builder.pages['']).to match(%r{<h1>Home page</h1>})

    expect(builder.pages['styles.css']).to match(/body/)
    expect(builder.pages['/this-is-the-title/section-1/subsection-1a']).to match(/<html>/)
    expect(builder.pages['/this-is-the-title/section-1/subsection-1a']).to match(%r{<a href="/this-is-the-title/section-1">Section 1</a>})
    expect(builder.pages['/this-is-the-title/section-1/subsection-1a']).to match(%r{<h1>Subsection 1.A</h1>})
  end

  specify '.write' do
    begin
      dir = Pathname.new(File.join(__dir__, 'output'))
      pages = {
        '/main.css' => 'do not touch this'
      }
      Docco.write(pages, output_dir: dir, overwrite: false)

      pages = {
        '' => 'Home page',
        '/main.css' => 'touched',
        '/section-1' => 'Section 1',
        '/section-1/section-1a' => 'Section 1.A',
        '/assets/styles.css' => 'CSS here'
      }

      report = Docco.write(pages, output_dir: dir, overwrite: false)
      expect((dir / 'main.css').read).to eq('do not touch this')
      expect((dir / 'index.html').read).to eq('Home page')
      expect((dir / 'section-1' / 'index.html').read).to eq('Section 1')
      expect((dir / 'section-1' / 'section-1a' / 'index.html').read).to eq('Section 1.A')
      expect((dir / 'assets' / 'styles.css').read).to eq('CSS here')
    ensure
      FileUtils.rm_rf(dir)
    end
  end
end
