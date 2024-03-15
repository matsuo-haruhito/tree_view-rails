# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'change password' do
    example 'update password change datetime' do
      user = create(:user)
      user.update(password_change_datetime: Time.current - 10)
      expect { user.update(password: 'new_password') }.to(change { user.password_change_datetime })
    end

    example 'jti is null' do
      user = create(:user)
      expect(user.jti).to eq nil
      expect { user.update(password: 'new_password') }.not_to(change { user.jti })
    end

    example 'jti is not null' do
      user = create(:user)
      user.update(jti: 'foo')
      expect(user.jti).not_to eq nil
      expect { user.update(password: 'new_password') }.to(change { user.jti })
    end
  end

  describe 'safe_order' do
    it 'string' do
      expect(User.safe_order('name', 'asc').to_sql).to include 'ORDER BY "users"."name" ASC NULLS LAST'
      expect(User.safe_order('name', 'desc').to_sql).to include 'ORDER BY "users"."name" DESC NULLS LAST'
    end

    it 'symbol' do
      expect(User.safe_order(:name, :asc).to_sql).to include 'ORDER BY "users"."name" ASC NULLS LAST'
      expect(User.safe_order(:name, :desc).to_sql).to include 'ORDER BY "users"."name" DESC NULLS LAST'
    end

    it 'ignore case' do
      expect(User.safe_order('NaMe', 'AsC').to_sql).to include 'ORDER BY "users"."name" ASC NULLS LAST'
      expect(User.safe_order('NaMe', 'DeSc').to_sql).to include 'ORDER BY "users"."name" DESC NULLS LAST'
      expect(User.safe_order(:nAmE, :aSc).to_sql).to include 'ORDER BY "users"."name" ASC NULLS LAST'
      expect(User.safe_order(:nAmE, :dEsC).to_sql).to include 'ORDER BY "users"."name" DESC NULLS LAST'
    end

    it 'one argument' do
      expect(User.safe_order('name').to_sql).to include 'ORDER BY "users"."name" ASC NULLS LAST'
    end

    it 'invalid argument' do
      expect(User.safe_order('foo', 'asc').to_sql).not_to include 'ORDER BY'
      expect(User.safe_order('name', 'foo').to_sql).not_to include 'ORDER BY'
      expect(User.safe_order(nil, nil).to_sql).not_to include 'ORDER BY'
    end
  end

  describe 'order_by' do
    example 'basic' do
      expect(User.order_by('name').to_sql).to include 'ORDER BY "users"."name" ASC NULLS LAST'
      expect(User.order_by('-name').to_sql).to include 'ORDER BY "users"."name" DESC NULLS LAST'
    end

    example 'multiple' do
      expect(User.order_by('name,furigana').to_sql).to include 'ORDER BY "users"."name" ASC NULLS LAST, "users"."furigana" ASC NULLS LAST'
      expect(User.order_by('name,-furigana').to_sql).to include 'ORDER BY "users"."name" ASC NULLS LAST, "users"."furigana" DESC NULLS LAST'
    end
  end
end
