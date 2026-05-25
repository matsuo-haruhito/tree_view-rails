# frozen_string_literal: true

require "spec_helper"

RSpec.describe TreeView::RenderContext do
  let(:tree) { double("tree") }
  let(:ui_config) { double("ui_config", mode: :static) }
  let(:presenter) do
    TreeView::NodePresenter.define do
      label { |item| item.fetch(:name) }
      href { |item| "/nodes/#{item.fetch(:id)}" }
    end
  end
  let(:render_state) do
    TreeView::RenderState.new(
      tree: tree,
      root_items: [],
      row_partial: "nodes/row",
      row_actions_partial: "nodes/actions",
      row_locals: {custom: :value},
      ui_config: ui_config,
      node_presenter: presenter
    )
  end
  let(:render_context) { described_class.new(render_state: render_state) }
  let(:item) { {id: 12, name: "Folder"} }
  let(:row_context) { TreeView::RowContext.new(render_context: render_context, item: item, depth: 1) }

  describe "#row_partial_locals" do
    it "provides stable row partial locals including the configured node presenter" do
      expect(render_context.row_partial_locals(item: item, row_context: row_context)).to eq(
        custom: :value,
        item: item,
        tree: tree,
        render_state: render_state,
        row_context: row_context,
        node_presenter: presenter
      )
    end
  end

  describe "#row_actions_partial_locals" do
    it "provides matching row action locals" do
      expect(render_context.row_actions_partial_locals(item: item, row_context: row_context)).to eq(
        item: item,
        tree: tree,
        render_state: render_state,
        row_context: row_context,
        node_presenter: presenter
      )
    end
  end

  context "when node_presenter is not configured" do
    let(:render_state) do
      TreeView::RenderState.new(
        tree: tree,
        root_items: [],
        row_partial: "nodes/row",
        ui_config: ui_config
      )
    end

    it "omits node_presenter from injected locals" do
      expect(render_context.row_partial_locals(item: item, row_context: row_context)).to eq(
        item: item,
        tree: tree,
        render_state: render_state,
        row_context: row_context
      )
    end
  end
end
