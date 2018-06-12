class CreateDegrees < ActiveRecord::Migration[5.1]
  def change
    if table_exists? :degrees
      drop_table :degrees
    end

    create_table :degrees do |t|
    	t.references :division, foreign_key: true
    	
    	t.string :code
    	t.string :name
      t.integer :years
    	
      t.timestamps
    end
  end
end
