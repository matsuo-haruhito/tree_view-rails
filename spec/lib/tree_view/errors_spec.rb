require "spec_helper"

RSpec.describe "TreeView exception classes" do
  it "defines a base TreeView error" do
    expect(TreeView::Error.superclass).to eq(StandardError)
  end

  it "defines categorized TreeView errors" do
    expect(TreeView::ConfigurationError.superclass).to eq(TreeView::Error)
    expect(TreeView::InvalidTreeError.superclass).to eq(TreeView::Error)
    expect(TreeView::UnsupportedModeError.superclass).to eq(TreeView::Error)
    expect(TreeView::RenderError.superclass).to eq(TreeView::Error)
  end
end
