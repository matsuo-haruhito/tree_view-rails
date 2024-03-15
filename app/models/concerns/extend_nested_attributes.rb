# frozen_string_literal: true

module ExtendNestedAttributes
  extend ActiveSupport::Concern

  class_methods do
    # accepts_nested_attributes_forにオプションauto_destroyを追加する
    # フォームから送信されなかった子レコードを自動的に削除する
    # input type='hidden' で _destroyを送信する手間を省ける
    def accepts_nested_attributes_for(*attr_names)
      options = attr_names.extract_options!
      auto_destroy = options.delete(:auto_destroy)

      super(*attr_names, options)

      return unless auto_destroy

      attr_names.each do |name|
        define_method(:"#{name}_attributes=") do |attributes|
          super(ExtendNestedAttributes.add_destroy_attributes(self, name, attributes))
        end
      end
    end
  end

  # attributesに含まれなかったレコード削除するように { id, _destroy } を追加する
  def self.add_destroy_attributes(record, name, attributes)
    if attributes.is_a?(Hash)
      attributes = attributes.map do |_index, hash|
        hash
      end
    end

    if record.new_record?
      attributes.each do |attribute|
        # 新規の時にidがあっても邪魔なだけなので削除する
        attribute.delete(:id)
      end
    end

    destroy_ids = record.send(name).ids - attributes.pluck(:id).map(&:to_i)
    destroy_attributes = destroy_ids.map do |id|
      { id: id, _destroy: true }
    end

    attributes + destroy_attributes
  end
end
