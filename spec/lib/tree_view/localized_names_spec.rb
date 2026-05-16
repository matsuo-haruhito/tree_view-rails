# frozen_string_literal: true

require "spec_helper"
require "active_model"

class LocalizedNamesTestDocument
  include ActiveModel::Model
  attr_accessor :title
end

class LocalizedNamesPlainDocument
end

LocalizedNamesTypedNode = Struct.new(:node_type, keyword_init: true)

RSpec.describe TreeView::LocalizedNames do
  around do |example|
    I18n.backend.store_translations(
      :en,
      activemodel: {
        models: {
          localized_names_test_document: {
            one: "Document",
            other: "Documents"
          }
        },
        attributes: {
          localized_names_test_document: {
            title: "Title"
          }
        }
      },
      tree_view: {
        node_types: {
          folder: "Folder"
        }
      }
    )

    example.run
  ensure
    I18n.reload!
  end

  it "resolves model names through ActiveModel and I18n" do
    expect(described_class.model_name_for(LocalizedNamesTestDocument)).to eq("Document")
    expect(described_class.model_name_for(LocalizedNamesTestDocument, count: 2)).to eq("Documents")
    expect(TreeView.model_name_for(LocalizedNamesTestDocument.new)).to eq("Document")
  end

  it "resolves attribute names through ActiveModel and I18n" do
    expect(described_class.attribute_name_for(LocalizedNamesTestDocument, :title)).to eq("Title")
    expect(TreeView.attribute_name_for(LocalizedNamesTestDocument.new, :title)).to eq("Title")
  end

  it "resolves node type names through tree_view.node_types translations" do
    node = LocalizedNamesTypedNode.new(node_type: :folder)

    expect(described_class.type_name_for(node)).to eq("Folder")
    expect(TreeView.type_name_for(node)).to eq("Folder")
  end

  it "falls back to humanized class and attribute names" do
    expect(described_class.model_name_for(LocalizedNamesPlainDocument)).to eq("Localized Names Plain Document")
    expect(described_class.attribute_name_for(LocalizedNamesPlainDocument, :published_at)).to eq("Published at")
  end

  it "falls back to humanized node type names" do
    node = LocalizedNamesTypedNode.new(node_type: :generated_folder)

    expect(described_class.type_name_for(node)).to eq("Generated folder")
  end
end
