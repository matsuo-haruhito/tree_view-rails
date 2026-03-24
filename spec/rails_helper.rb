# frozen_string_literal: true

# This file is copied to spec/ when you run 'rails generate rspec:install'
require 'spec_helper'
ENV['RAILS_ENV'] = 'test'
require File.expand_path('../config/environment', __dir__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production?
require 'rspec/rails'
require 'capybara/rspec'
# Add additional requires below this line. Rails is not loaded until this point!

Capybara.register_driver :selenium_chromium_headless do |app|
  chrome_options = Selenium::WebDriver::Chrome::Options.new
  %w[headless no-sandbox disable-dev-shm-usage window-size=1600,1200].each do |argument|
    chrome_options.add_argument(argument)
  end

  chrome_binary = %w[
    /usr/bin/chromium-browser
    /usr/bin/chromium
    /usr/bin/google-chrome-stable
    /usr/bin/google-chrome
  ].find { |path| File.exist?(path) }
  chrome_options.binary = chrome_binary if chrome_binary

  service = Selenium::WebDriver::Service.chrome(path: ENV.fetch('CHROMEDRIVER_PATH', '/usr/bin/chromedriver'))

  Capybara::Selenium::Driver.new(app, browser: :chrome, options: chrome_options, service: service)
end

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
# Dir[Rails.root.join('spec', 'support', '**', '*.rb')].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove these lines.
begin
  ActiveRecord::Migration.maintain_test_schema!
rescue ActiveRecord::PendingMigrationError => e
  puts e.to_s.strip
  exit 1
end
RSpec.configure do |config|
  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_paths = [Rails.root.join('spec/fixtures').to_s]

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")

  # devise
  config.include Devise::Test::IntegrationHelpers, type: :request
  # config.include Devise::Test::ControllerHelpers, type: :controller
  config.include Devise::Test::ControllerHelpers, type: :view
  config.include Warden::Test::Helpers
  config.include Warden::Test::Helpers, type: :system

  # FactoryBot
  config.include FactoryBot::Syntax::Methods

  config.before(:suite) do
    Warden.test_mode!
  end

  config.before(type: :system) do |example|
    if example.metadata[:js]
      driven_by :selenium_chromium_headless
    else
      driven_by :rack_test
    end
  end

  config.before(type: :system) do
    Capybara.save_path = Rails.root.join('tmp/screenshots')
  end

  config.after(type: :system) do |example|
    if page&.current_window && page.driver.respond_to?(:save_screenshot)
      FileUtils.mkdir_p(Capybara.save_path)
      screenshot_name = example.full_description.parameterize(separator: '_')
      page.save_screenshot(Rails.root.join('tmp/screenshots', "#{screenshot_name}.png"))
    end

    Warden.test_reset!
  end

  config.after(:suite) do
    Warden.test_reset!
  end
end
