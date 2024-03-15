# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FontAwesome5Helper, type: :helper do
  describe 'fa_icon' do
    example do
      expect(fa_icon('fas', 'clock')).to include 'class="fas fa-clock"'
      expect(fa_icon('fas', 'clock flip-horizontal')).to include 'class="fas fa-clock fa-flip-horizontal"'
      expect(fa_icon('fas', 'clock', nil, class: 'foo')).to include 'class="fas fa-clock foo"'
    end
  end

  describe 'far' do
    example do
      expect(far('clock')).to include 'class="far fa-clock"'
    end
  end

  describe 'fas' do
    example do
      expect(fas('clock')).to include 'class="fas fa-clock"'
    end
  end
end
