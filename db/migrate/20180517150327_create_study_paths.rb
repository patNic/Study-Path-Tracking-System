class CreateStudyPaths < ActiveRecord::Migration[5.1]
  def change
    if table_exists? :study_paths
      drop_table :study_paths
    end
    
    create_table :study_paths do |t|
    	t.references :degree, foreign_key: true
    	#t.references :subject, foreign_key: true

      t.string :program_revision_code
      t.string :title

      t.timestamps
    end
  end
end
