# frozen_string_literal: true

module WebApiModel
  class << self
    def included(model_class)
      model_class.const_set(:WebApi, Module.new do
        class << self
          def index(params)
            result = module_parent.all

            result = WebApiModel.search(result, params[:q]) if params[:q].present?

            result = if params[:order].present?
                       WebApiModel.order(result, params[:order])
                     else
                       result.order(:id)
                     end

            result = result.includes(WebApiModel.parse_include(params[:include])) if params[:include].present?

            result
              .page(params[:page])
              .per(params[:per])
          end
        end
      end)
    end

    # <name><operator><value>の形式で文字列を渡すとその条件で検索する
    # 存在しないフィールドが指定された場合は無視する
    def search(relation, query)
      result = relation
      result if query.blank?

      model_class = relation.model

      parse_query(query).each do |param|
        next unless model_class.has_attribute?(param[:name])

        conditions = if param[:operator] == '='
                       { param[:name] => param[:value] }
                     else
                       ["#{param[:name]} #{param[:operator]} ?", param[:value]]
                     end

        result = if param[:not] == true
                   result.where.not(conditions)
                 else
                   result.where(conditions)
                 end
      end

      result
    end

    # 'name' → name昇順
    # '-name' → name降順
    # 'name,created_at' → 複合ソート
    def order(relation, order)
      result = relation

      orders = parse_order(order)

      orders.each do |hash|
        result = result.order({ hash[:sort] => hash[:order] })
      end

      result = result.order(:id) unless orders.any? { |hash| hash[:sort] == 'id' }

      result
    end

    def parse_query(text)
      return [] if text.blank?

      result = []

      regexp = /((?<name>-?[a-z._]+):(?<operator>[<>=]*))(?<value>([^"[:blank:]]+|".+(?!\\)"))/

      text.scan(regexp).each do |name, operator, value|
        result << {
          name: name.delete_prefix('-'),
          operator: operator.in?(%w[< > <= >=]) ? operator : '=',
          value: JSON.parse(value),
          not: name.start_with?('-')
        }
      rescue StandardError
        # do nothing
      end

      result
    end

    def parse_order(text)
      return [] if text.blank?

      text.split(',').map do |value|
        if value.start_with?('-')
          { sort: value.delete_prefix('-'), order: 'desc' }
        else
          { sort: value, order: 'asc' }
        end
      end
    end

    def parse_include(text)
      return [] if text.blank?

      text.split(',').map do |value|
        value.split('.').reverse.reduce({}) do |hash, name|
          { name.to_sym => hash }
        end
      end
    end
  end
end
