# frozen_string_literal: true

module TreeView
  class Tree
    DEFAULT_SORTER = lambda do |items, tree|
      items.sort_by { |item| tree.descendant_counts[tree.node_key_for(item)].to_i }
    end

    VALID_ORPHAN_STRATEGIES = %i[ignore as_root raise orphans_only].freeze

    attr_reader :records,
                :id_method,
                :parent_id_method,
                :roots,
                :children_resolver,
                :adapter,
                :sorter,
                :orphan_strategy

    def initialize(records: nil,
                   parent_id_method: nil,
                   id_method: :id,
                   roots: nil,
                   children_resolver: nil,
                   node_key_resolver: nil,
                   adapter: nil,
                   sorter: nil,
                   orphan_strategy: :ignore)
      @records = records
      @id_method = id_method
      @parent_id_method = parent_id_method
      @roots = Array(roots)
      @children_resolver = children_resolver
      @node_key_resolver = node_key_resolver
      @adapter = adapter
      @sorter = sorter || DEFAULT_SORTER
      @orphan_strategy = normalize_orphan_strategy(orphan_strategy)

      validate_mode!
    end

    def items_by_parent_id
      return {} if adapter_mode? || resolver_mode?

      @items_by_parent_id ||= records.group_by { |record| record.public_send(parent_id_method) }
    end

    def descendant_counts
      @descendant_counts ||= begin
        memo = {}
        visiting = {}

        count_descendants = lambda do |record|
          node_key = node_key_for(record)
          return memo[node_key] if memo.key?(node_key)
          raise ArgumentError, "cycle detected in tree for node #{node_key.inspect}" if visiting[node_key]

          visiting[node_key] = true
          children = children_for(record)
          memo[node_key] = children.sum { |child| 1 + count_descendants.call(child) }
          visiting.delete(node_key)
          memo[node_key]
        rescue StandardError
          visiting.delete(node_key)
          raise
        end

        each_root_candidate do |root_candidate|
          count_descendants.call(root_candidate)
        end

        memo
      end
    end

    def root_items(root_parent_id = nil)
      candidates = if adapter_mode?
        adapter.roots
      elsif resolver_mode?
        roots
      elsif root_parent_id.nil?
        root_items_for_nil_parent
      else
        Array(items_by_parent_id[root_parent_id])
      end

      sort_items(candidates)
    end

    def children_for(record)
      return adapter.children_for(record) if adapter_mode?
      return Array(children_resolver.call(record)) if resolver_mode?

      Array(items_by_parent_id[record.public_send(id_method)])
    end

    def parent_for(record)
      ensure_records_path_helpers!

      parent_id = record.public_send(parent_id_method)
      return nil if parent_id.nil?

      items_by_id[parent_id]
    end

    def ancestors_for(record)
      ensure_records_path_helpers!

      ancestors = []
      visiting = {}
      current = record

      loop do
        current_key = node_key_for(current)
        raise ArgumentError, "cycle detected in parent path for node #{current_key.inspect}" if visiting[current_key]

        visiting[current_key] = true
        parent = parent_for(current)
        break unless parent

        ancestors.unshift(parent)
        current = parent
      end

      ancestors
    end

    def path_for(record)
      ancestors_for(record) + [record]
    end

    def paths_for(items)
      Array(items).map { |item| path_for(item) }
    end

    def path_tree_for(items)
      TreeView::PathTree.new(base_tree: self, paths: paths_for(items))
    end

    def node_key_for(record)
      if adapter_mode?
        adapter.node_key_for(record, id_method: id_method)
      elsif @node_key_resolver
        @node_key_resolver.call(record)
      elsif resolver_mode?
        [record.class.name, record.public_send(id_method)]
      else
        record.public_send(id_method)
      end
    end

    def sort_items(items)
      sorted = sorter.call(Array(items), self)
      if sorted.nil? || !sorted.respond_to?(:to_a)
        raise ArgumentError, "sorter must return an Array-like object, got: #{sorted.class}"
      end

      sorted.to_a
    end

    def orphan_items
      return [] unless records_mode?

      @orphan_items ||= records.select do |record|
        parent_id = record.public_send(parent_id_method)
        parent_id && !items_by_id.key?(parent_id)
      end
    end

    def validate_unique_node_keys!
      seen = {}
      duplicated_keys = []

      each_root_candidate do |item|
        node_key = node_key_for(item)
        if seen.key?(node_key)
          duplicated_keys << node_key unless duplicated_keys.include?(node_key)
        else
          seen[node_key] = true
        end
      end

      if duplicated_keys.any?
        raise ArgumentError, "duplicate node_key detected: #{duplicated_keys.map(&:inspect).join(', ')}"
      end

      true
    end

    private

    def adapter_mode?
      adapter.is_a?(TreeView::GraphAdapter)
    end

    def resolver_mode?
      children_resolver.respond_to?(:call)
    end

    def records_mode?
      !adapter_mode? && !resolver_mode?
    end

    def ensure_records_path_helpers!
      return if records_mode?

      raise ArgumentError, "parent path helpers are only supported in records mode"
    end

    def each_root_candidate
      return enum_for(:each_root_candidate) unless block_given?

      if adapter_mode?
        adapter.roots.each { |root| yield root }
      elsif resolver_mode?
        roots.each { |root| yield root }
      else
        items_by_parent_id.each_value do |items|
          items.each { |item| yield item }
        end
      end
    end

    def root_items_for_nil_parent
      regular_roots = Array(items_by_parent_id[nil])

      case orphan_strategy
      when :ignore
        regular_roots
      when :as_root
        regular_roots + orphan_items
      when :raise
        raise_if_orphans!
        regular_roots
      when :orphans_only
        orphan_items
      end
    end

    def raise_if_orphans!
      return if orphan_items.empty?

      orphan_keys = orphan_items.map { |item| node_key_for(item).inspect }.join(', ')
      raise ArgumentError, "orphan nodes detected: #{orphan_keys}"
    end

    def items_by_id
      @items_by_id ||= records.to_h { |record| [record.public_send(id_method), record] }
    end

    def normalize_orphan_strategy(value)
      normalized_value = value.to_sym
      return normalized_value if VALID_ORPHAN_STRATEGIES.include?(normalized_value)

      raise ArgumentError, "orphan_strategy must be one of: #{VALID_ORPHAN_STRATEGIES.join(', ')}"
    end

    def validate_mode!
      raise ArgumentError, "sorter must respond to call" unless sorter.respond_to?(:call)

      if adapter_mode?
        raise ArgumentError, 'adapter mode cannot be combined with records mode' if records || parent_id_method
        raise ArgumentError, 'adapter mode cannot be combined with roots/children_resolver mode' if roots.any? || children_resolver
        raise ArgumentError, 'orphan_strategy is only supported in records mode' unless orphan_strategy == :ignore
      elsif resolver_mode?
        raise ArgumentError, 'roots must be provided when children_resolver is used' if roots.empty?
        raise ArgumentError, 'orphan_strategy is only supported in records mode' unless orphan_strategy == :ignore
      else
        raise ArgumentError, 'records and parent_id_method are required in records mode' if records.nil? || parent_id_method.nil?
      end
    end
  end
end
