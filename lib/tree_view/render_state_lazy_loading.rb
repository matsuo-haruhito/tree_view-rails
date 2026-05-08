# frozen_string_literal: true

require "tree_view/render_state/lazy_loading_config"

module TreeView
  module RenderStateLazyLoading
    VALID_LAZY_LOADING_KEYS = RenderState::LazyLoadingConfig::VALID_KEYS

    attr_reader :lazy_loading_config,
      :lazy_loading_enabled,
      :lazy_loading_loaded_keys,
      :lazy_loading_scope

    def initialize(**options)
      @lazy_loading_config = RenderState::LazyLoadingConfig.new(
        enabled: options.delete(:lazy_loading_enabled),
        loaded_keys: options.delete(:lazy_loading_loaded_keys),
        scope: options.delete(:lazy_loading_scope),
        lazy_loading: options.delete(:lazy_loading)
      )
      @lazy_loading_enabled = lazy_loading_config.enabled
      @lazy_loading_loaded_keys = lazy_loading_config.loaded_keys
      @lazy_loading_scope = lazy_loading_config.scope

      super
      validate_lazy_loading_config_mode_contract!
    end

    def lazy_loading_enabled?
      lazy_loading_config.enabled?
    end

    private

    def validate_lazy_loading_config_mode_contract!
      return unless lazy_loading_enabled?
      return unless ui_config.respond_to?(:client?) && ui_config.client?

      raise TreeView::ConfigurationError, "lazy_loading cannot be enabled with client-side toggle mode; use turbo mode for remote child loading or disable lazy_loading"
    end
  end
end

TreeView::RenderState.prepend(TreeView::RenderStateLazyLoading)
