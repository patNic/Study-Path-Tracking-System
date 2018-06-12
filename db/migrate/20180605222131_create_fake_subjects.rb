class CreateFakeSubjects < ActiveRecord::Migration[5.1]
  def change
    if table_exists? :fake_subjects
      drop_table :fake_subjects
    end
    
    create_table :fake_subjects do |t|
      t.string :subject_code
      
       t.timestamps
    end
  end
end
