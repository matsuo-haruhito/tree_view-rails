require "spec_helper"
require "logger"

RSpec.describe TreeView::Configuration do
  describe "#initial_state=" do
    it "accepts expanded and collapsed" do
      config = described_class.new(initial_state: :expanded)

      config.initial_state = :collapsed

      expect(config.initial_state).to eq(:collapsed)
    end

    it "rejects invalid values" do
      config = described_class.new

      expect { config.initial_state = :invalid }.to raise_error(ArgumentError, /initial_state/)
    end

    it "rejects non-symbolizable values with a clear error" do
      config = described_class.new

      expect { config.initial_state = nil }.to raise_error(ArgumentError, /initial_state must be one of/)
      expect { config.initial_state = 1 }.to raise_error(ArgumentError, /initial_state must be one of/)
    end
  end

  describe "#render_log_level=" do
    it "defaults to warn" do
      config = described_class.new

      expect(config.render_log_level).to eq(:warn)
    end

    it "accepts logger level names" do
      config = described_class.new

      config.render_log_level = :info

      expect(config.render_log_level).to eq(:info)
    end

    it "accepts logger level constants" do
      config = described_class.new

      config.render_log_level = Logger::ERROR

      expect(config.render_log_level).to eq(:error)
    end

    it "accepts nil to disable TreeView render log silencing" do
      config = described_class.new

      config.render_log_level = nil

      expect(config.render_log_level).to be_nil
    end

    it "rejects invalid values" do
      config = described_class.new

      expect { config.render_log_level = :verbose }.to raise_error(ArgumentError, /render_log_level/)
      expect { config.render_log_level = Object.new }.to raise_error(ArgumentError, /render_log_level/)
    end
  end
end
