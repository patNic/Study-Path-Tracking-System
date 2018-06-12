class AdminsController < ApplicationController
    def dashboard
      @title = "Admin Dashboard"
    end
    def add_study_path
      @title = "Add Study Path"
    end
    def view_study_path
      @study_paths = StudyPath.all
      
      @study_path_courses = []
      
      @study_paths.each do |s|
        puts "Degree ID #{ s.degree_id}"
        degree = Degree.find_by id: s.degree_id
        puts s.id 
        @study_path_courses << {degree: degree, study_path_id: s.id}
        puts "Name "+ degree.name 
      end
       @is_remove = false
       @title = "View Study Path"
    end
    def remove_study_path
      view_study_path
      @title = 'Remove Study Path'
      @is_remove = true
      
      render 'view_study_path'
      @title = "Remove Study Path"
    end
    def delete_certain_study_path
      @id = params['id']
      
      (StudyPath.find_by id: @id).destroy
      redirect_to '/admin/remove_study_path'
      @title = "Removing Study Path"
    end
    def show
     @all_subjects = Subject.all
     puts "Params id #{params[:id]}"
     @studypath = StudyPath.find_by id: params[:id]
     @program = Degree.find_by id: @studypath.degree_id
      
     @years = ["First", "Second", "Third", "Fourth", "Fifth"].take(@program.years)
     @semesters = ["First", "Second", "Summer"]

		 @subjects = Array.new
 
		 @years.each do |year|
			@semesters.each do |semester|
				sps = StudyPathSubject.where(["study_path_id = ? and year = ? and semester = ?", @studypath.id, year, semester]).distinct
				subjs = Array.new
        
				sps.each do |subj|
          if(subj.subject_id.nil?)
            if subj.rgep.nil?
            else
              subjs << (RgepCluster.find_by id: subj.rgep)
            end
          else
            subjs << Subject.find(subj.subject_id)
          end
				end

				if !semester.eql? "Summer"
					entry = {:year => year, :semester => semester, :subjects => subjs}
					@subjects << entry
				end

				if year.eql? "Third" and semester.eql? "Summer"
					entry = {:year => year, :semester => semester, :subjects => subjs}
					@subjects << entry
				end
			end
      
      @title = "Study Path"
		end
    end
    def edit
    end
    
    def destroy
    end
end
