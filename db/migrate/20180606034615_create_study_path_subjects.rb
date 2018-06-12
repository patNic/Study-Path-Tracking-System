class CreateStudyPathSubjects < ActiveRecord::Migration[5.1]
  def change
    create_table :study_path_subjects do |t|
    	t.integer :study_path_id
    	t.integer :subject_id
    	t.integer :rgep
    	t.string :year
    	t.string :semester

    	t.timestamps
    end
  end
end
