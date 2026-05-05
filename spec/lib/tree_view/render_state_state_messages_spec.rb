require "spec_helper"

RSpec.describe "TreeView::RenderState state messages" do
  let(:tree) { instance_double(TreeView::Tree) }
  let(:ui_config) { instance_double(TreeView::UiConfig) }

  def build_state(**options)
    TreeView::RenderState.new(
      tree: tree,
      root_items: [],
      row_partial: "items/tree_columns",
      ui_config: ui_config,
      **options
    )
  end

  it "stores empty and hidden message options" do
    hidden_builder = ->(count) { "#{count} hidden" }

    state = build_state(
      empty_message: "No rows",
      hidden_message_builder: hidden_builder
    )

    expect(state.empty_message).to eq("No rows")
    expect(state.hidden_message_builder).to eq(hidden_builder)
  end

  it "stores grouped state message options" do
    hidden_builder = ->(count) { "#{count} hidden" }

    state = build_state(
      state_messages: {
        empty: "No rows",
        hidden_builder: hidden_builder
      }
    )

    expect(state.empty_message).to eq("No rows")
    expect(state.hidden_message_builder).to eq(hidden_builder)
  end

  it "prefers individual options over grouped state message options" do
    grouped_builder = ->(count) { "grouped #{count}" }
    individual_builder = ->(count) { "individual #{count}" }

    state = build_state(
      empty_message: "Individual empty",
      hidden_message_builder: individual_builder,
      state_messages: {
        empty: "Grouped empty",
        hidden_builder: grouped_builder
      }
    )

    expect(state.empty_message).to eq("Individual empty")
    expect(state.hidden_message_builder).to eq(individual_builder)
  end

  it "rejects unknown grouped state message keys" do
    expect do
      build_state(state_messages: {empty: "No rows", unknown: true})
    end.to raise_error(ArgumentError, /state_messages contains unknown keys: unknown/)
  end

  it "rejects invalid hidden message builders" do
    expect do
      build_state(hidden_message_builder: :invalid)
    end.to raise_error(ArgumentError, /hidden_message_builder/)
  end
end
