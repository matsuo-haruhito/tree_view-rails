class CreateRparamMemories < ActiveRecord::Migration[6.0]
  def change
    create_table :rparam_memories do |t|
      t.references :user, polymorphic: true, index: true
      t.string :action
      t.string :value

      t.timestamps
    end
  end
end
