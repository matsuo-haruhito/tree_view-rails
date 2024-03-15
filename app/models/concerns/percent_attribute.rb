# frozen_string_literal: true

# 百分率をdbでは小数で管理して、入力は%単位で入力したい時に使う
# [使用例]
# カラム名rateがあったとしてmodelに以下の記述を追加する
#
# percent_attribute :rate
#
# 以下2つのメソッドが追加されるので、元々のカラムの代わりに
# formとstrong parameterでこれを指定する
# rate_percent
# rate_percent=
module PercentAttribute
  extend ActiveSupport::Concern

  class_methods do
    def percent_attribute(name)
      define_method :"#{name}_percent" do
        value = self[name]
        return nil if value.nil?

        percent = value * 100

        if percent.to_i == percent
          # 小数点以下が0だと切り捨てる
          percent.to_i
        else
          percent
        end
      end

      define_method :"#{name}_percent=" do |value|
        if value.blank?
          self[name] = nil
        else
          percent = value.to_d
          self[name] = percent / 100
        end
      end
    end
  end
end
