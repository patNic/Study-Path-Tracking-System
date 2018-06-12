class CreateDivisions < ActiveRecord::Migration[5.1]
  def change
  	if table_exists? :divisions
  		drop_table :divisions
  	end

    create_table :divisions do |t|
    	t.string :name
    	
      t.timestamps
    end
  end
end
