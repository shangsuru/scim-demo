class AddJoinTableGroupsUsers < ActiveRecord::Migration[7.1]
  def change
    create_table :groups_users, id: false do | t |
      t.references :group, foreign_key: true, type: :int8, index: true, null: false
      t.references :user,                     type: :uuid, index: true, null: false, primary_key: :primary_key

      t.foreign_key :users, primary_key: :primary_key
    end
  end
end
