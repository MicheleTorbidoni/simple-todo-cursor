# frozen_string_literal: true

class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name, null: false
      t.boolean :completed, null: false, default: false

      t.timestamps
    end

    add_index :tasks, [ :user_id, :created_at ]
  end
end
