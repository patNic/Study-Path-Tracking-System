class StudyPathSubject < ApplicationRecord
	belongs_to :study_path, required: false
	belongs_to :subject, required: false
end
