# frozen_string_literal: true

module TreeView
  module LocalizedNames
    module_function

    def model_name_for(item_or_class, count: 1, default: nil)
      model_class = class_for(item_or_class)

      if model_class.respond_to?(:model_name) && model_class.model_name.respond_to?(:human)
        return model_class.model_name.human(count: count, default: default)
      end

      default || humanize_identifier(model_class.name || model_class.to_s)
    end

    def attribute_name_for(item_or_class, attribute, default: nil)
      model_class = class_for(item_or_class)
      attribute_name = attribute.to_s

      if model_class.respond_to?(:human_attribute_name)
        return model_class.human_attribute_name(attribute_name, default: default)
      end

      default || humanize_identifier(attribute_name)
    end

    def type_name_for(item, count: 1, default: nil)
      return model_name_for(item, count: count, default: default) unless item.respond_to?(:node_type)

      node_type = item.node_type
      return default || humanize_identifier(node_type) if node_type.nil? || node_type.to_s.empty?

      i18n_key = "tree_view.node_types.#{node_type}"
      if defined?(I18n)
        translated = I18n.t(i18n_key, count: count, default: nil)
        return translated unless translated.nil?
      end

      default || humanize_identifier(node_type)
    end

    def humanize_identifier(value)
      value.to_s
        .split("::")
        .last
        .gsub(/([a-z\d])([A-Z])/, "\\1 \\2")
        .tr("_", " ")
        .strip
        .then { |text| text.empty? ? text : text[0].upcase + text[1..] }
    end

    def class_for(item_or_class)
      item_or_class.is_a?(Class) ? item_or_class : item_or_class.class
    end
  end
end
