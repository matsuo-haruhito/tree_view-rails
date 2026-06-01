# frozen_string_literal: true

require "spec_helper"

RSpec.describe "mockup inventory" do
  let(:repo_root) { File.expand_path("..", __dir__) }
  let(:mockups_dir) { File.join(repo_root, "docs/mockups") }
  let(:readme_path) { File.join(mockups_dir, "README.md") }
  let(:review_gallery_path) { File.join(mockups_dir, "review-gallery.html") }
  let(:audit_path) { File.join(repo_root, "docs/i18n-audit.md") }

  def actual_mockup_assets
    Dir.children(mockups_dir)
      .select { |name| File.file?(File.join(mockups_dir, name)) }
      .sort
  end

  def actual_gallery_pages
    actual_mockup_assets.grep(/\.html\z/) - ["review-gallery.html"]
  end

  def readme_inventory
    File.read(readme_path)
      .scan(/\[([A-Za-z0-9._-]+\.(?:html|css|md))\]\(\1\)/)
      .flatten
      .uniq
      .sort
  end

  def review_gallery_inventory
    File.read(review_gallery_path)
      .scan(/<iframe[^>]+src="([A-Za-z0-9._-]+\.html)"/)
      .flatten
      .uniq
      .sort
  end

  def audit_inventory_policy
    File.read(audit_path)
  end

  it "keeps the mockup README inventory aligned with the actual asset set" do
    expect(readme_inventory).to eq(actual_mockup_assets - ["README.md"])
  end

  it "keeps the review gallery previews aligned with the actual HTML mockup pages" do
    expect(review_gallery_inventory).to eq(actual_gallery_pages)
  end

  it "keeps the documentation maintenance checklist pointed at the mockup README as the inventory source" do
    expect(audit_inventory_policy).to include(
      "`docs/mockups/README.md` is the source of truth for the current static mockup file inventory",
      "Its Files table is also the source read by the browser smoke target list",
      "Top-level `docs/mockups/*.html` files listed in the mockup README",
      "Focused subpage assets linked from the mockup README",
      "Update this technical-assets section only when the source-of-truth rule or asset-group responsibility changes"
    )
  end
end
