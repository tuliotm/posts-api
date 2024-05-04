# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[7.1]
  def change
    create_table(:users) do |t|
      t.string(:login, null: false)

      t.timestamps
    end
    add_index(:users, :login, unique: true)
  end
end
