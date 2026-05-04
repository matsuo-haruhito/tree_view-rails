# frozen_string_literal: true

module TreeView
  module RenderStatePersistedState
    attr_reader :persisted_state

    def initialize(**options)
      @persisted_state = PersistedState.from(options.delete(:persisted_state))
      options[:expanded_keys] = persisted_state.expanded_keys if options[:expanded_keys].nil? && persisted_state

      super(**options)
    end

    def view_key
      super || persisted_state&.view_key
    end
  end
end

TreeView::RenderState.prepend(TreeView::RenderStatePersistedState)
