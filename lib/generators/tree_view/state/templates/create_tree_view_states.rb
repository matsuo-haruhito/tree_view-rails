# frozen_string_literal: true

class CreateTreeViewStates < ActiveRecord::Migration[7.1]
  def change
    create_table :tree_view_states do |t|
      t.references :owner, polymorphic: true, null: false
      t.string :view_key, null: false
      t.json :expanded_keys, null: false, default: []
      t.timestamps
    end

    add_index :tree_view_states, [:owner_type, :owner_id, :view_key], unique: true
  end
end
