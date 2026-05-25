# frozen_string_literal: true

require "spec_helper"

RSpec.describe "tree_view stylesheet source" do
  let(:stylesheet_source) { File.read(File.expand_path("../../app/assets/stylesheets/tree_view.scss", __dir__)) }

  it "adds a distinct focus-visible state for tree toggle actions" do
    aggregate_failures do
      expect(stylesheet_source).to include(".tree-toggle__action:focus-visible")
      expect(stylesheet_source).to include("outline: 2px solid rgba(13, 110, 253, 0.75);")
      expect(stylesheet_source).to include("background-color: rgba(13, 110, 253, 0.12);")
    end
  end

  it "keeps hover styling separate from keyboard focus styling" do
    aggregate_failures do
      expect(stylesheet_source).to include(".tree-toggle__action:hover")
      expect(stylesheet_source).to include("background-color: rgba(108, 117, 125, 0.08);")
      expect(stylesheet_source).to include(".tree-toggle__action:focus:not(:focus-visible)")
    end
  end
end
