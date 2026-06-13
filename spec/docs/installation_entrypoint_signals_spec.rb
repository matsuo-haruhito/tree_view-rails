# frozen_string_literal: true

require "spec_helper"

RSpec.describe "installation entrypoint signal docs" do
  def read_repo_file(path)
    File.read(File.expand_path("../../#{path}", __dir__))
  end

  let(:english_installation) { read_repo_file("docs/en/installation.md") }
  let(:japanese_installation) { read_repo_file("docs/ja/installation.md") }

  it "keeps CSS import, importmap pin, and controller registration signals visible" do
    {
      "docs/en/installation.md" => english_installation,
      "docs/ja/installation.md" => japanese_installation
    }.each do |path, document|
      expect(document).to include(
        '@import "tree_view";',
        'pin "tree_view", to: "tree_view/index.js"',
        'import { registerTreeViewControllers } from "tree_view"',
        "registerTreeViewControllers(application)"
      ), "#{path} lost one of the representative installation entrypoint signals"
    end
  end

  it "keeps Propshaft and Sprockets setup signals separate from the quick-start path" do
    expect(english_installation).to include(
      "## Propshaft",
      "explicitly import CSS and add the importmap pin",
      "## Sprockets",
      "explicit CSS/importmap setup in the host app remains the recommended integration path"
    )

    expect(japanese_installation).to include(
      "## Propshaft",
      "CSS / importmap を明示的に読み込む構成を推奨します",
      "## Sprockets",
      "導入の中心はhost app側でCSS / importmapを明示的に読み込む運用です"
    )
  end
end
