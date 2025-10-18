# frozen_string_literal: true

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
end
