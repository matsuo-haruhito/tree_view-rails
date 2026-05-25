# frozen_string_literal: true

require "spec_helper"

RSpec.describe TreeView::PersistedStateController do
  let(:controller_class) do
    Class.new do
      include TreeView::PersistedStateController
    end
  end

  let(:controller) { controller_class.new }

  describe "#save_tree_view_persisted_state!" do
    it "normalizes expanded keys before delegating to StateStore" do
      owner = double(:owner)
      model = Class.new
      persisted_state = TreeView::PersistedState.new(
        tree_instance_key: "projects:sidebar",
        expanded_keys: ["project:1", "folder:2"]
      )
      store = instance_double(TreeView::StateStore, save!: persisted_state)

      allow(controller).to receive(:tree_view_state_store).with(model: model).and_return(store)

      result = controller.send(
        :save_tree_view_persisted_state!,
        model: model,
        owner: owner,
        tree_instance_key: "projects:sidebar",
        expanded_keys: [" project:1 ", nil, "", :folder_2]
      )

      expect(store).to have_received(:save!).with(
        owner: owner,
        tree_instance_key: "projects:sidebar",
        expanded_keys: ["project:1", "folder_2"]
      )
      expect(result).to eq(persisted_state)
    end
  end

  describe "#normalize_tree_view_expanded_keys" do
    it "accepts comma-separated strings from lightweight endpoints" do
      expect(controller.send(:normalize_tree_view_expanded_keys, " project:1, folder:2 ,,document:3 ")).to eq(
        ["project:1", "folder:2", "document:3"]
      )
    end

    it "returns an empty array for nil" do
      expect(controller.send(:normalize_tree_view_expanded_keys, nil)).to eq([])
    end
  end
end
