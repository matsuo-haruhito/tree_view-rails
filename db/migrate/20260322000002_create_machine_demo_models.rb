class CreateMachineDemoModels < ActiveRecord::Migration[8.0]
  def change
    create_table :machines do |t|
      t.string :name, null: false
      t.references :parent_machine, foreign_key: { to_table: :machines }, index: true
      t.timestamps
    end

    create_table :units do |t|
      t.string :name, null: false
      t.references :machine, foreign_key: true, null: false
      t.references :parent_unit, foreign_key: { to_table: :units }, index: true
      t.timestamps
    end

    create_table :parts do |t|
      t.string :name, null: false
      t.references :machine, foreign_key: true, index: true
      t.references :unit, foreign_key: true, index: true
      t.timestamps
    end

    create_table :materials do |t|
      t.string :name, null: false
      t.references :part, foreign_key: true, null: false
      t.timestamps
    end
  end
end
