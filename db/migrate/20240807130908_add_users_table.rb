class AddUsersTable < ActiveRecord::Migration[7.1]
  def change
    create_table :users, id: :uuid, primary_key: :primary_key do |t|
      t.timestamps

      # Part of the core schema
      t.text :scim_uid
      t.text :username
      t.text :password
      t.text :first_name
      t.text :last_name
      t.text :work_email_address
      t.text :home_email_address
      t.text :work_phone_number

      # Custom extension schema
      t.text :organization
      t.text :department
      t.text :manager
    end
  end
end
