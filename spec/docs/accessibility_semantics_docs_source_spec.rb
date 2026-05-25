# frozen_string_literal: true

require "spec_helper"

RSpec.describe "accessibility semantics docs sources" do
  let(:english_source) { File.read(File.expand_path("../../docs/en/accessibility-semantics.md", __dir__)) }
  let(:japanese_source) { File.read(File.expand_path("../../docs/ja/accessibility-semantics.md", __dir__)) }

  it "documents the focus-visible baseline and host app override expectation" do
    aggregate_failures do
      expect(english_source).to include("The shipped stylesheet adds a lightweight `.tree-toggle__action:focus-visible` ring and background")
      expect(english_source).to include("Host apps can override or replace that baseline in copied CSS.")
      expect(japanese_source).to include("default stylesheet では `.tree-toggle__action:focus-visible` に軽量な ring と背景色を付けています。")
      expect(japanese_source).to include("host app は copied stylesheet や上書き CSS でこの baseline を置き換えられます。")
    end
  end
end
