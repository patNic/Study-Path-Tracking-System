class CreateAdmin < ActiveRecord::Migration[5.1]
  def change
    create_table :admins do |t|
      t.string :user_name
      t.string :password
      
      t.timestamps
    end
  end
end
