# frozen_string_literal: true

class ActionController::Parameters
  # https://qiita.com/vochicong/items/d64f3b3d5a448a3b1f42
  # camelCaseのパラメータをsnake_caseに自動変換する
  def deep_snakeize!
    @parameters.deep_transform_keys!(&:underscore)
    self
  end

  # 配列のパラメータに対して連番を設定する
  def sequence(attribute)
    number = 1
    each do |_key, hash|
      hash[attribute] = number
      number += 1
    end
  end
end
