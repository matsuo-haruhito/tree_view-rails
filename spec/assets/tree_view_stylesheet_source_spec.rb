# frozen_string_literal: true

require "spec_helper"

RSpec.describe "tree_view stylesheet source" do
  let(:stylesheet_source) { File.read(File.expand_path("../../app/assets/stylesheets/tree_view.scss", __dir__)) }

  it "adds a distinct focus-visible state for tree toggle actions" do
    aggregate_failures do
      expect(stylesheet_source).to include(".tree-toggle__action:focus-visible")
      expect(stylesheet_source).to include("outline: 2px solid var(--tree-view-focus-outline-color, rgba(13, 110, 253, 0.75));")
      expect(stylesheet_source).to include("background-color: var(--tree-view-focus-background, rgba(13, 110, 253, 0.12));")
    end
  end

  it "keeps hover styling separate from keyboard focus styling" do
    aggregate_failures do
      expect(stylesheet_source).to include(".tree-toggle__action:hover")
      expect(stylesheet_source).to include("background-color: var(--tree-view-toggle-hover-background, rgba(108, 117, 125, 0.08));")
      expect(stylesheet_source).to include(".tree-toggle__action:focus:not(:focus-visible)")
    end
  end

  it "keeps the LTR branch connector selectors visible for future direction-aware review" do
    aggregate_failures do
      expect(stylesheet_source).to include(<<~CSS.strip)
        .tree-toggle__branch-slot.has-line::before{
          content: "";
          position: absolute;
          top: -0.35rem;
          bottom: -0.35rem;
          left: 50%;
      CSS
      expect(stylesheet_source).to include(<<~CSS.strip)
        .tree-toggle__branch-slot.is-current::after{
          content: "";
          position: absolute;
          top: 50%;
          left: 50%;
          right: 0;
      CSS
    end
  end

  it "keeps the current-row cue anchored to the first rendered table cell" do
    expect(stylesheet_source).to include(<<~CSS.strip)
      .tree-row[aria-current="page"] > td:first-child{
        box-shadow: inset 3px 0 0 var(--tree-view-current-row-accent-color, rgba(13, 110, 253, 0.45));
      }
    CSS
  end
end
