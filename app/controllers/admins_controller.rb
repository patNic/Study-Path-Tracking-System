class AdminsController < ApplicationController
    def dashboard
      @title = "Admin Dashboard"
    end
    def add_study_path
      @title = "Add Study Path"
    end
    def new_subject
     @title = "New Subject"
     begin
      if(!(params.empty?))
          @new_fake_subject = FakeSubject.create subject_code: params[:subject][:subject_code]
          pre_req = params[:subject][:pre_req].split(",")
         
          if(pre_req.length == 0)
            division_id = (Division.find_by name: params[:subject][:division]).id
        
            begin
              unit = params[:subject][:units].to_i
              
              if(unit == 0)
                "" + 2
              end
              @new = Subject.create(division_id: division_id, subject_id: params[:subject][:subject_code], name: params[:subject][:name], pre_req: params[:subject][:pre_req],
              description: params[:subject][:description], units: unit, isGe: params[:subject][:isGE], rgep: params[:subject][:rgep])
        
              if(@new.nil?)
                flash[:new_subject] = "Error in creating new subject"
                FakeSubject.destroy @new_fake_subject.id
              else
                flash[:new_subject] = "Successful in creating new subject"
              end
            rescue Exception => exc
              puts "One #{exc.message}"
              logger.error("Message for the log file #{exc.message}")
              flash[:new_subject] = "Error in creating new subject. Please fill the necessary fields with appropriate values."
              FakeSubject.destroy @new_fake_subject.id
            end
         else
            begin
              division_id = (Division.find_by name: params[:subject][:division]).id
              unit = params[:subject][:units].to_i
              if(unit == 0)
                "" + 2
              end
              pre_req.each do |p|
                fake = FakeSubject.find_by subject_code: p.strip
                @new = Subject.create(division_id: division_id, fake_subject_id: fake.id, subject_id: params[:subject][:subject_code], name: params[:subject][:name], pre_req: params[:subject][:pre_req],
                description: params[:subject][:description], units: unit, isGe: params[:subject][:isGE], rgep: params[:subject][:rgep])
        
                if(@new.nil?)
                  flash[:new_subject] = "Failure in creating new subject"
                  FakeSubject.destroy @new_fake_subject.id
                else
                  flash[:new_subject] = "Successful in creating new subject"
                end
              end
            rescue Exception => exc
              puts "Two #{exc.message}"
              logger.error("Message for the log file #{exc.message}")
              flash[:new_subject] = "Error in creating new subject. Please fill the necessary fields with appropriate values."
              FakeSubject.destroy @new_fake_subject.id
            end
          end
      end
    rescue Exception => exc
       puts "Three #{exc.message}"
       logger.error("Message for the log file #{exc.message}")
       flash[:new_subject] = "Error in creating new subject. Please fill the necessary fields with appropriate values."
       FakeSubject.destroy @new_fake_subject.id
    end
      render 'add_new_subject'
    end
    def add_new_subject
      @title = "Add New Subject"
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
