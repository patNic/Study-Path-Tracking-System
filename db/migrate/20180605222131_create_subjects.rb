class CreateSubjects < ActiveRecord::Migration[5.1]
  def change
    if table_exists? :subjects
      drop_table :subjects
    end

    create_table :subjects do |t|
    	t.references :division, foreign_key: true
    	t.references :fake_subject, foreign_key: true
      
    	t.string :subject_id
    	t.string :name
      t.string :pre_req
    	t.string :description
    	t.integer :units
    	t.boolean :isGe
      t.string :rgep
    	
      t.timestamps
    end
  end
end
