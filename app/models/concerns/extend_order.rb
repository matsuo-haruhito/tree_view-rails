# frozen_string_literal: true

module ExtendOrder
  extend ActiveSupport::Concern

  included do
    scope :safe_order, lambda { |name, order = 'asc'|
      name = name.to_s.downcase

      return unless model.attribute_names.include? name

      sort = "\"#{model.table_name}\".\"#{name}\""

      if 'asc'.casecmp? order.to_s
        order("#{sort} ASC NULLS LAST")
      elsif 'desc'.casecmp? order.to_s
        order("#{sort} DESC NULLS LAST")
      end
    }

    scope :left_join_as, lambda { |name|
      reflection = model.reflect_on_association(name)
      joins(
        "LEFT OUTER JOIN \"#{reflection.table_name}\" \"#{name}\" " +
        "ON \"#{name}\".\"id\" = \"#{table_name}\".\"#{reflection.foreign_key}\""
      )
    }

    scope :order_by, lambda { |sort|
      result = self

      return result if sort.nil?

      config = ActiveSupport::HashWithIndifferentAccess.new(model.order_by_config)

      sort.split(',').each do |sort|
        order = if sort.start_with?('-')
                  sort = sort.delete_prefix('-')
                  'DESC'
                else
                  'ASC'
                end

        result = if config[sort].present?
                   result.instance_exec(order, &config[sort])
                 else
                   result.safe_order(sort, order)
                 end
      end

      result
    }
  end

  module ClassMethods
    def order_names(config)
      @order_by_config = config
    end

    attr_reader :order_by_config
  end
end
