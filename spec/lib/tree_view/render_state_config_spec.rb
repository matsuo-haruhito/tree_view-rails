# frozen_string_literal: true

require "spec_helper"

RSpec.describe "RenderState configuration objects" do
  describe TreeView::RenderState::SelectionConfig do
    it "normalizes grouped selection options" do
      payload_builder = ->(item) { {id: item.id} }

      config = described_class.new(
        selection: {
          enabled: true,
          visibility: :leaves,
          payload_builder: payload_builder,
          checkbox_name: "documents[]",
          selected_keys: ["document:1"],
          cascade: true,
          indeterminate: true,
          max_count: 3
        },
        default_checkbox_name: "selected_nodes[]"
      )

      expect(config).to be_enabled
      expect(config.visibility).to eq(:leaves)
      expect(config.payload_builder).to eq(payload_builder)
      expect(config.checkbox_name).to eq("documents[]")
      expect(config.selected_keys).to eq(["document:1"])
      expect(config).to be_cascade
      expect(config).to be_indeterminate
      expect(config.max_count).to eq(3)
    end

    it "keeps individual selection options ahead of grouped options" do
      config = described_class.new(
        selectable: true,
        checkbox_name: "override[]",
        selection: {
          enabled: false,
          checkbox_name: "grouped[]"
        },
        default_checkbox_name: "selected_nodes[]"
      )

      expect(config).to be_enabled
      expect(config.checkbox_name).to eq("override[]")
    end
  end

  describe TreeView::RenderState::LazyLoadingConfig do
    it "normalizes grouped lazy loading options" do
      config = described_class.new(
        lazy_loading: {
          enabled: true,
          loaded_keys: ["node:1"],
          scope: "children"
        }
      )

      expect(config).to be_enabled
      expect(config.loaded_keys).to eq(["node:1"])
      expect(config.scope).to eq("children")
    end

    it "keeps individual lazy loading options ahead of grouped options" do
      config = described_class.new(
        enabled: false,
        loaded_keys: ["node:2"],
        lazy_loading: {
          enabled: true,
          loaded_keys: ["node:1"]
        }
      )

      expect(config).not_to be_enabled
      expect(config.loaded_keys).to eq(["node:2"])
    end
  end
end
