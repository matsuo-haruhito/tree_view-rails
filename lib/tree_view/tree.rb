# frozen_string_literal: true

module TreeView
  class Tree
    attr_reader :records, :id_method, :parent_id_method, :roots, :children_resolver, :adapter

    def initialize(records: nil,
                   parent_id_method: nil,
                   id_method: :id,
                   roots: nil,
                   children_resolver: nil,
                   node_key_resolver: nil,
                   adapter: nil)
      @records = records
      @id_method = id_method
      @parent_id_method = parent_id_method
      @roots = Array(roots)
      @children_resolver = children_resolver
      @node_key_resolver = node_key_resolver
      @adapter = adapter

      validate_mode!
    end

    def items_by_parent_id
      return {} if adapter_mode? || resolver_mode?

      @items_by_parent_id ||= records.group_by { |record| record.public_send(parent_id_method) }
    end

    def descendant_counts
      @descendant_counts ||= begin
        memo = {}

        count_descendants = lambda do |record|
          node_key = node_key_for(record)
          return memo[node_key] if memo.key?(node_key)

          children = children_for(record)
          memo[node_key] = children.sum { |child| 1 + count_descendants.call(child) }
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
      else
        Array(items_by_parent_id[root_parent_id])
      end
      candidates.sort_by { |item| descendant_counts[node_key_for(item)] }
    end

    def children_for(record)
      return adapter.children_for(record) if adapter_mode?
      return Array(children_resolver.call(record)) if resolver_mode?

      Array(items_by_parent_id[record.public_send(id_method)])
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

    private

    def adapter_mode?
      adapter.is_a?(TreeView::GraphAdapter)
    end

    def resolver_mode?
      children_resolver.respond_to?(:call)
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

    def validate_mode!
      if adapter_mode?
        raise ArgumentError, 'adapter mode cannot be combined with records mode' if records || parent_id_method
        raise ArgumentError, 'adapter mode cannot be combined with roots/children_resolver mode' if roots.any? || children_resolver
      elsif resolver_mode?
        raise ArgumentError, 'roots must be provided when children_resolver is used' if roots.empty?
      else
        raise ArgumentError, 'records and parent_id_method are required in records mode' if records.nil? || parent_id_method.nil?
      end
    end
  end
end
