class AddGroupsTable < ActiveRecord::Migration[7.1]
  def change
    create_table :groups do |t|
      t.text :scim_uid
      t.text :display_name

      t.references :parent
    end
  end
end
