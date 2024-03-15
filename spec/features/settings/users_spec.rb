# frozen_string_literal: true

require 'rails_helper'

RSpec.feature 'Users', type: :feature do
  scenario 'change current user password' do
    user = create(:user)

    login_as user

    visit edit_settings_user_path(user)

    fill_in 'user[password]', with: 'new_password'
    click_on 'commit_password'

    expect(page).to have_content 'ログアウト'
  end
end
