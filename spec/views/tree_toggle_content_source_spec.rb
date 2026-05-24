# frozen_string_literal: true

require "spec_helper"

RSpec.describe "tree toggle content partial sources" do
  let(:static_source) { File.read(File.expand_path("../../app/views/tree_view/_tree_toggle_content_static.html.erb", __dir__)) }
  let(:client_source) { File.read(File.expand_path("../../app/views/tree_view/_tree_toggle_content_client.html.erb", __dir__)) }
  let(:turbo_source) { File.read(File.expand_path("../../app/views/tree_view/_tree_toggle_content_turbo.html.erb", __dir__)) }

  it "uses the localized hidden descendants suffix in every toggle mode" do
    aggregate_failures do
      expect(static_source).to include('hidden_descendants_sr_text = t("tree_view.accessibility.hidden_descendants", default: " descendants")')
      expect(client_source).to include('hidden_descendants_sr_text = t("tree_view.accessibility.hidden_descendants", default: " descendants")')
      expect(turbo_source).to include('hidden_descendants_sr_text = t("tree_view.accessibility.hidden_descendants", default: " descendants")')
    end
  end

  it "keeps the visually hidden suffix next to hidden count output in every toggle mode" do
    aggregate_failures do
      expect(static_source).to include('<span class="visually-hidden"><%= hidden_descendants_sr_text %></span>')
      expect(client_source).to include('<span class="visually-hidden"><%= hidden_descendants_sr_text %></span>')
      expect(turbo_source).to include('<span class="visually-hidden"><%= hidden_descendants_sr_text %></span>')
    end
  end
end
