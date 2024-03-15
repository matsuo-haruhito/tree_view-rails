class CreateItems < ActiveRecord::Migration[7.1]
  def change
    create_table :items, comment: '商品' do |t|
      t.string :parent_item_id, comment: '親商品id'
      t.string :name, comment: '商品名'
      t.string :comment, comment: 'コメント'
      t.date :usage_start_date, comment: "使用開始日"
      t.date :usage_end_date, comment: "使用終了日"

      t.references :create_user, comment: '作成者id'
      t.references :update_user, comment: '更新者id'
      t.timestamps
    end
  end
end
