# frozen_string_literal: true

require "spec_helper"

RSpec.describe "Public initial_state configuration contract" do
  it "keeps the documented accepted values stable" do
    expect(TreeView::Configuration::VALID_INITIAL_STATES).to eq(%i[expanded collapsed])
  end

  it "normalizes accepted initial_state values from symbols and strings" do
    configuration = TreeView::Configuration.new(initial_state: :expanded)
    expect(configuration.initial_state).to eq(:expanded)

    configuration.initial_state = "collapsed"
    expect(configuration.initial_state).to eq(:collapsed)
  end

  it "rejects values outside the documented initial_state contract" do
    configuration = TreeView::Configuration.new

    expect { configuration.initial_state = :invalid }.to raise_error(
      TreeView::ConfigurationError,
      /initial_state must be one of: expanded, collapsed/
    )
  end
end
