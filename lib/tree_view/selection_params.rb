# frozen_string_literal: true

require "json"

module TreeView
  module SelectionParams
    module_function

    def parse(value)
      Array(value).filter_map do |entry|
        next if entry.nil? || entry == ""

        parse_entry(entry)
      end
    end

    def parse_entry(entry)
      return entry.to_h if entry.respond_to?(:to_h) && !entry.is_a?(String)
      raise ArgumentError, "selection params entries must be JSON strings or Hash-like objects" unless entry.is_a?(String)

      parsed = JSON.parse(entry)
      return parsed if parsed.is_a?(Hash)

      raise ArgumentError, "selection params entries must parse to JSON objects"
    rescue JSON::ParserError => e
      raise ArgumentError, "invalid selection params JSON: #{e.message}"
    end
  end
end
