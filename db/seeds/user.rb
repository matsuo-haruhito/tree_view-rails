# frozen_string_literal: true

def user

  return if User.any?

  User.create(
    username: 'admin',
    password: 'admin',
    name: '管理者',
    furigana: 'かんりしゃ',
    admin: true,
  )

  1.upto 10 do |i|
    User.create(
      username: "user#{i}",
      password: "user#{i}",
      name: "ユーザ#{i}",
      furigana: "ゆーざ#{i}",
    )
  end

end
