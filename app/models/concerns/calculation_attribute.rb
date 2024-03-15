# frozen_string_literal: true

module CalculationAttribute
  extend ActiveSupport::Concern

  class_methods do
    # 他のカラムからの計算で決まるカラム
    def calculation_attribute(name, proc)
      before_validation do
        value = instance_exec(&proc)
        self[name] = value
      end

      define_method name do
        instance_exec(&proc)
      end
    end
  end
end
