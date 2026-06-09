# frozen_string_literal: true

require "spec_helper"
require "logger"

RSpec.describe "Render log level public contract" do
  after do
    TreeView.reset_configuration!
  end

  it "keeps documented render_log_level symbol values aligned with Configuration" do
    expect(TreeView::Configuration::VALID_RENDER_LOG_LEVELS.keys).to eq(%i[debug info warn error fatal unknown])

    TreeView::Configuration::VALID_RENDER_LOG_LEVELS.each_key do |level|
      TreeView.configure do |config|
        config.render_log_level = level
      end

      expect(TreeView.configuration.render_log_level).to eq(level)
    end
  end

  it "normalizes Ruby Logger level constants to their public symbol values" do
    expected_levels = {
      Logger::DEBUG => :debug,
      Logger::INFO => :info,
      Logger::WARN => :warn,
      Logger::ERROR => :error,
      Logger::FATAL => :fatal,
      Logger::UNKNOWN => :unknown
    }

    expected_levels.each do |logger_constant, expected_level|
      TreeView.configure do |config|
        config.render_log_level = logger_constant
      end

      expect(TreeView.configuration.render_log_level).to eq(expected_level)
    end
  end

  it "keeps nil as the public boundary for disabling TreeView render log silencing" do
    TreeView.configure do |config|
      config.render_log_level = nil
    end

    expect(TreeView.configuration.render_log_level).to be_nil
  end

  it "rejects values outside the documented render log level contract" do
    expect do
      TreeView.configure do |config|
        config.render_log_level = :verbose
      end
    end.to raise_error(TreeView::ConfigurationError, /render_log_level/)

    expect do
      TreeView.configure do |config|
        config.render_log_level = Object.new
      end
    end.to raise_error(TreeView::ConfigurationError, /render_log_level/)
  end
end
