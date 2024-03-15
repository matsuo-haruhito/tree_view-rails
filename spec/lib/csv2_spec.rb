# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Csv2 do
  describe 'read' do
    example 'shift-jis' do
      path = File.expand_path('data/shift-jis.csv', __dir__)
      csv = Csv2.read(path)
      expect(csv.size).to eq 2
      expect(csv.class).to eq Array
      expect(csv[0][1]).to eq '名前'
    end

    example 'utf-8' do
      path = File.expand_path('data/utf-8.csv', __dir__)
      csv = Csv2.read(path)
      expect(csv.size).to eq 2
      expect(csv.class).to eq Array
      expect(csv[0][1]).to eq '名前'
    end

    example 'option' do
      path = File.expand_path('data/utf-8.csv', __dir__)
      csv = Csv2.read(path, headers: true)
      expect(csv.size).to eq 1
      expect(csv.class).to eq CSV::Table
    end
  end
end
