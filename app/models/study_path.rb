class StudyPath < ApplicationRecord
	has_many :study_path_subjects
	has_many :subjects, :through => :study_path_subjects
end
