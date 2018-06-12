class Subject < ApplicationRecord
	has_many :study_path_subjects
	has_many :study_paths, :through => :study_path_subjects
end
