require 'rails_helper'

RSpec.describe TreeView::Configuration do
  describe '#initial_state=' do
    it 'expanded と collapsed を受け付ける' do
      config = described_class.new(initial_state: :expanded)

      config.initial_state = :collapsed

      expect(config.initial_state).to eq(:collapsed)
    end

    it '不正な値は受け付けない' do
      config = described_class.new

      expect { config.initial_state = :invalid }.to raise_error(ArgumentError, /initial_state/)
    end
  end
end
