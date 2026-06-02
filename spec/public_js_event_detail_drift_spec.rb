# frozen_string_literal: true

require "spec_helper"
require "yaml"

RSpec.describe "Public JavaScript event detail drift" do
  PUBLIC_API_MANIFEST_PATH = File.expand_path("../config/public_api_manifest.yml", __dir__)
  JAVASCRIPT_CONTROLLER_PATHS = {
    "state" => File.expand_path("../app/javascript/tree_view/state_controller.js", __dir__),
    "selection" => File.expand_path("../app/javascript/tree_view/selection_controller.js", __dir__),
    "remote_state" => File.expand_path("../app/javascript/tree_view/remote_state_controller.js", __dir__),
    "transfer" => File.expand_path("../app/javascript/tree_view/transfer_controller.js", __dir__)
  }.freeze

  def public_javascript_event_detail_keys
    YAML.safe_load_file(PUBLIC_API_MANIFEST_PATH).fetch("javascript_package_root").fetch("event_detail_keys")
  end

  def javascript_controller_source(group_name)
    File.read(JAVASCRIPT_CONTROLLER_PATHS.fetch(group_name))
  end

  def event_dispatch_name(event_key)
    event_key.tr("_", "-")
  end

  def source_dispatch_windows(source, dispatch_name)
    matcher = /\b(?:dispatch|dispatch[A-Za-z]*)\("#{Regexp.escape(dispatch_name)}"/

    source.to_enum(:scan, matcher).map do
      start_index = Regexp.last_match.begin(0)
      end_index = source.index(/\n  }\n/, start_index) || source.length

      source[start_index...end_index]
    end
  end

  def object_body_after_key(source, key)
    source.to_enum(:scan, /#{Regexp.escape(key)}\s*:\s*\{/).map do
      open_brace_index = source.index("{", Regexp.last_match.begin(0))

      object_body(source, open_brace_index)
    end.compact
  end

  def object_body(source, open_brace_index)
    return nil unless open_brace_index

    depth = 0
    body_start = open_brace_index + 1

    source[open_brace_index..].each_char.with_index(open_brace_index) do |char, index|
      depth += 1 if char == "{"
      depth -= 1 if char == "}"

      return source[body_start...index] if depth.zero?
    end

    nil
  end

  def first_argument_object_body(window)
    open_brace_index = window.index("{")

    object_body(window, open_brace_index)
  end

  def detail_object_bodies(window)
    bodies = object_body_after_key(window, "detail")
    return bodies unless bodies.empty?

    # dispatchTransferEvent(name, detail) treats the second argument as the public detail object.
    return [first_argument_object_body(window)].compact if window.match?(/\bdispatchTransferEvent\("/)

    []
  end

  def source_mentions_shorthand_detail?(window)
    window.match?(/\bdetail\s*[},]/)
  end

  def method_return_object_body(source, method_name)
    method_source = source[/\n  #{Regexp.escape(method_name)}\([^)]*\) \{.*?\n  \}/m]
    return nil unless method_source

    open_brace_index = method_source.index("{", method_source.index(/\breturn\s*\{/))

    object_body(method_source, open_brace_index)
  end

  def object_key_names(body)
    return [] unless body

    explicit_keys = body.scan(/(?:^|[,{]\s*)([A-Za-z_$][\w$]*)\s*:/m).flatten
    shorthand_keys = body.scan(/(?:^|[,{]\s*)([A-Za-z_$][\w$]*)\s*(?=,|\z)/m).flatten

    (explicit_keys + shorthand_keys).uniq
  end

  def source_detail_keys_for_dispatch(source, dispatch_name)
    source_dispatch_windows(source, dispatch_name).flat_map do |window|
      keys = detail_object_bodies(window).flat_map { |body| object_key_names(body) }

      if source_mentions_shorthand_detail?(window)
        keys.concat(object_key_names(method_return_object_body(source, "selectionDetail")))
      end

      keys
    end.uniq
  end

  it "keeps controller dispatch detail keys registered in the public manifest" do
    public_javascript_event_detail_keys.each do |group_name, events|
      source = javascript_controller_source(group_name)

      events.each do |event_key, manifest_keys|
        dispatch_name = event_dispatch_name(event_key)
        source_keys = source_detail_keys_for_dispatch(source, dispatch_name)
        undocumented_keys = source_keys - manifest_keys

        expect(undocumented_keys).to be_empty,
          "expected #{group_name} #{dispatch_name} detail keys #{source_keys.inspect} " \
          "to stay within manifest keys #{manifest_keys.inspect}; " \
          "add public keys to config/public_api_manifest.yml or keep private details out of the public dispatch payload"
      end
    end
  end
end
