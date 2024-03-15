# frozen_string_literal: true

def notice

  return if Notice.any?

  user_ids = User.ids

  notices = []

  100.times do

    publish_start_datetime = Faker::Time.between(from: 1.year.ago, to: 1.month.after)

    if Faker::Boolean.boolean(true_ratio: 0.1)
      publish_end_datetime = Faker::Time.between(
        from: publish_start_datetime, to: publish_start_datetime.next_month
      )
    else
      publish_end_datetime = nil
    end

    notices << {
      title: Faker::Lorem.sentence,
      body: Faker::Lorem.paragraph,
      publish_start_datetime: publish_start_datetime,
      publish_end_datetime: publish_end_datetime,
      create_user_id: user_ids.sample,
      update_user_id: user_ids.sample,
      created_at: Time.current,
      updated_at: Time.current,
    }
  end

  Notice.insert_all notices

end
