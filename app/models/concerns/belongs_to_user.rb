# frozen_string_literal: true

module BelongsToUser
  extend ActiveSupport::Concern

  module ClassMethods
    def belongs_to_user(options = nil)
      options ||= {}
      prefix = options[:prefix]

      name = if prefix.present?
               "#{prefix}_user"
             else
               'user'
             end

      foreign_key = "#{name}_id"

      belongs_to(name.to_sym,
                 class_name: 'User',
                 foreign_key: foreign_key,
                 optional: true)

      define_method :"#{name}_name" do
        return if self[foreign_key].nil?

        user = send(name)

        if user.nil?
          ApplicationController.helpers.tag.small '削除済のユーザ'
        else
          user.name
        end
      end
    end
  end

  def created_by(user)
    self.create_user_id = user&.id if has_attribute? :create_user_id
    updated_by(user)
  end

  def updated_by(user)
    self.update_user_id = user&.id if has_attribute? :update_user_id
    self.updated_at = Time.current
  end
end
