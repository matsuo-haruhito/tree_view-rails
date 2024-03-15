class CreateNotices < ActiveRecord::Migration[6.0]
  def change
    create_table :notices, comment: 'お知らせ' do |t|
      t.string :title, comment: 'タイトル'
      t.text :body, comment: '本文'
      t.datetime :publish_start_datetime, comment: '公開開始日時'
      t.datetime :publish_end_datetime, comment: '公開終了日時'

      t.references :create_user, comment: '作成者id'
      t.references :update_user, comment: '更新者id'
      t.timestamps
    end
  end
end
