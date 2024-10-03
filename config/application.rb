require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module App
  class Application < Rails::Application
    # Initialize configuration defaults for originally generated Rails version.
    config.load_defaults 6.1

    # Please, add to the `ignore` list any other `lib` subdirectories that do
    # not contain `.rb` files, or that should not be reloaded or eager loaded.
    # Common ones are `templates`, `generators`, or `middleware`, for example.
    config.autoload_lib(ignore: %w[assets tasks])

    # Configuration for the application, engines, and railties goes here.
    #
    # These settings can be overridden in specific environments using the files
    # in config/environments, which are processed later.
    #
    # config.time_zone = "Central Time (US & Canada)"
    # config.eager_load_paths << Rails.root.join("extras")

    config.i18n.default_locale = :ja
    config.time_zone = 'Asia/Tokyo'
    config.active_record.default_timezone = :local
    config.action_controller.include_all_helpers = true
    config.action_view.form_with_generates_remote_forms = false
    config.active_storage.routes_prefix = :files

    # Don't generate system test files.
    config.generators.system_tests = nil

    # rack dev mark
    if ENV['RACK_DEV_MARK'].present?
      config.rack_dev_mark.enable = true
      config.rack_dev_mark.env = "#{ENV['RACK_DEV_MARK']}".force_encoding('UTF-8')
      config.rack_dev_mark.theme = [:title, Rack::DevMark::Theme::GithubForkRibbon.new(
        position: ENV.fetch('RACK_DEV_MARK_POSITION', nil),
        fixed: true,
        color: ENV.fetch('RACK_DEV_MARK_COLOR', nil)
      )]
    end

    # health check
    if Rails.env.production?
      require_dependency Rails.root.join('middleware/health_check')
      config.middleware.insert_before Rails::Rack::Logger, HealthCheck
    end

    Faker::Config.locale = :en if defined? Faker
  end
end
