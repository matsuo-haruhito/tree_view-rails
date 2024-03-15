# frozen_string_literal: true

Dir[Rails.root.join("app/core_ext/**/*.rb").to_s].each do |file|
  require file
end
