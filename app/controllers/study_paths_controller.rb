class StudyPathsController < ApplicationController
	before_action :access_crs

	def show
		@course = @student.basic_info
		@my_study_path = StudyPath.find_by degree_id: (Degree.find_by id: params["id"].gsub(".","")).id

		degree_id = Degree.where(name: @course['degree_program'].gsub(".","")).pluck(:id).first
		study_path_record = StudyPath.where(degree_id: degree_id).first

		@my_study_path = {id: study_path_record.id, program_revision_code: study_path_record.program_revision_code, title: study_path_record.title}				
		@my_subjects = StudyPathSubject.where(study_path_id: @my_study_path[:id])
		# puts "@my_subjects = #{@my_subjects}"
		# @my_subjects.each do |subject|

		@myGrades = @student.grades
		
		temp_year = ""
		temp_sem = ""

		@entries = Array.new	
		@entry_persem = Hash.new
		@subject_persem = []

		@my_subjects.each_with_index do |subject, index|			
			if temp_year == "" then temp_year = subject[:year] end
			if temp_sem == "" then temp_sem = subject[:semester] end

			if temp_year != subject[:year] || temp_sem != subject[:semester] || index == @my_subjects.length-1
				@entry_persem[:year] = temp_year
				@entry_persem[:sem] = temp_sem
				@entry_persem[:subjects] = @subject_persem				
				temp_year = subject[:year]
				temp_sem = subject[:semester]				
				@entries << @entry_persem
				@entry_persem = Hash.new
				@subject_persem = Array.new
			end

			entry = Hash.new
			if subject[:subject_id] == nil && subject[:rgep] != nil
				entry[:subject] = RgepCluster.where(id: subject[:rgep]).distinct.pluck(:name).first
				entry[:units] = "#{RgepCluster.where(id: subject[:rgep]).distinct.pluck(:units).first}.0"
			else
				entry[:subject] = Subject.where(id: subject[:subject_id]).distinct.pluck(:subject_id).first
				entry[:name] = Subject.where(id: subject[:subject_id]).distinct.pluck(:name).first
				entry[:units] = "#{Subject.where(id: subject[:subject_id]).distinct.pluck(:units).first}.0"				
			end			
			fake_subject_id = Subject.where(id: subject[:subject_id]).distinct.pluck(:fake_subject_id).join(",")
			fake_subject_name = FakeSubject.where(id: fake_subject_id).distinct.pluck(:subject_code).join(",")		
			entry[:prerequisites] = fake_subject_name

			@subject_persem << entry
		end
		
		@totalUnits = 0
		subjects_taken = Array.new
		# ah_taken = Array.new
		# ssp_taken = Array.new
		# mst_taken = Array.new
		# elective_taken = Array.new
		# pe_taken = Array.new
		# nstp_taken

		# puts @myGrades

		@myGrades.each do |sem|
			entry_persem = Array.new
			sem.each do |entries|				
				if entries.length > 1
					subject = Hash.new
					subject[:subject] = entries[:subj]
					subject[:name] = Subject.where(subject_id: "#{entries[:subj]}").distinct.pluck(:name).join(",")
					subject[:units] = entries[:units]
					subject[:prerequisites] = Subject.where(subject_id: "#{entries[:subj]}").distinct.pluck(:pre_req).join(",")
					subject[:grade] = entries[:finalGrade]


					if entries[:finalGrade].include? " INC " or entries[:finalGrade].include? " 4.0 "
						if !entries[:completionGrade].eql? " "
							subject[:grade] = entries[:completionGrade]
						end
					end

					if (!entries[:finalGrade].eql? " 5.0 " or !entries[:finalGrade].eql? " 4.0 " or !entries[:finalGrade].eql? " INC " or !entries[:finalGrade].eql? " NO GRADE ") and !entries[:units].include? "("
						@totalUnits = @totalUnits + entries[:units].to_i
					end

					if entries[:finalGrade].eql? " INC " and !entries[:completionGrade].eql? " NO GRADE "
						if (!entries[:completionGrade].eql? " 5.0 " or !entries[:completionGrade].eql? " 4.0 ") and !entries[:units].include? "("
							@totalUnits = @totalUnits + entries[:units].to_i
						end
					end

					entry_persem << subject
				end
			end
			subjects_taken << entry_persem
		end
    my_units = Array.new
    
    @myGrades.each do |content|
       my_units << content[(content.length - 1)][:subj]
    end
    
    @totalUnits = 0;
    my_units.each do |unit|
      @totalUnits = @totalUnits + unit[32, 4].to_i
    end
   
   @units = 0
    @elective_count = 0
    @entries.each_with_index do |entry, index|
        @entry_subjects = entry[:subjects]
        @first_sem_grade = @myGrades[index]
        
        @entry_subjects.each do |s|
          @units = @units + s[:units].to_i
        end
        if(!@first_sem_grade.nil?)        
          @first_sem_grade = long_cuts(@first_sem_grade)
          entry_subjects(@entry_subjects)
        end
    end
    @units = @units - 12
    @title = "Study Path"
end

  def entry_subjects(entry_subjects)
   
          entry_subjects.each_with_index do |ent, i|
                 if(ent[:subject] == "GE (AH)")
                    @first_sem_grade.each do |fs|
                      
                      subj = Subject.find_by subject_id: fs[:subj]
                      
                      if(!subj.nil?)
                        if(!subj.rgep.nil?)
                            if(subj.rgep.strip == "GE (AH)")
                              ent[:name] = fs[:subj]
                              ent[:grade] = fs[:finalGrade]
                              fs[:subj] = ""
                              break
                            end
                        end
                      end
                    end
                  elsif (ent[:subject] == "GE (SSP)")
                   @first_sem_grade.each do |fs|
                      
                      subj = Subject.find_by subject_id: fs[:subj]
                      
                      if(!subj.nil?)
                        if(!subj.rgep.nil?)
                            if(subj.rgep.strip == "GE (SSP)")
                              ent[:name] = fs[:subj]
                              ent[:grade] = fs[:finalGrade]
                              fs[:subj] = ""
                              break
                            end
                        end
                      end
                    end
                  elsif (ent[:subject] == "GE (MST)")
                    @first_sem_grade.each do |fs|
                      
                      subj = Subject.find_by subject_id: fs[:subj]
                      
                      if(!subj.nil?)
                        if(!subj.rgep.nil?)
                            
                            if(subj.rgep.strip == "GE (MST)")
                              ent[:name] = fs[:subj]
                              ent[:grade] = fs[:finalGrade]
                              fs[:subj] = ""
                              break
                            end
                        end
                      end
                  end
                  elsif (ent[:subject].include? "NSTP")
                    @first_sem_grade.each do |fs|
                        if(fs[:subj].include?"NSTP")
                          ent[:grade] = fs[:finalGrade]
                        end
                     end
                  elsif (ent[:subject].include? "P.E.")
                    @first_sem_grade.each do |fs|
                        if(fs[:subj].include?"PE")
                          ent[:grade] = fs[:finalGrade]
                          ent[:units] = 2.0
                        end
                     end
                  elsif (ent[:subject].include? "PE")
                    @first_sem_grade.each do |fs|
                        if(fs[:subj].include?"PE")
                          ent[:grade] = fs[:finalGrade]
                        end
                     end
                   elsif (ent[:subject] == "Elective")
                   @first_sem_grade.each do |fs|
                      subj = Subject.find_by subject_id: fs[:subj]
                      if(!subj.nil?)
                        if(!subj.rgep.nil?)
                            if(subj.rgep.strip == "Elective")
                                 ent[:name] = fs[:subj]
                                 ent[:grade] = fs[:finalGrade]
                                 fs[:subj] = ""
                                 break
                            end
                        end
                      end
                   end
                  else
                       @first_sem_grade.each do |fs|
                          if(ent[:subject] == fs[:subj])
                              ent[:grade] = fs[:finalGrade]
                          end
                          if(ent[:subject] == fs[:subj])
                              ent[:grade] = fs[:finalGrade]
                          end
                       end
                   end
             end
  end
	def new
		@title = 'SPTS - Add New Study Path'
	end

	def edit
		@title = 'SPTS - Edit Study Path'
	end

	def update
	end

	def destroy
	end

	def create
    @title = 'SPTS - New Study Path'
    
    if((StudyPath.find_by degree_id: (Degree.find_by name: params["study_path"]["degree_id"].gsub(".","")).id).nil?)
      @my_study_path = StudyPath.create(program_revision_code: params["study_path"]["program_revision_code"], title: params["study_path"]["title"],
      degree_id: (Degree.find_by name: params["study_path"]["degree_id"].gsub(".","")).id)
      @@subject_session = nil
    else
      @my_study_path = StudyPath.find_by degree_id: (Degree.find_by name: params["study_path"]["degree_id"].gsub(".","")).id
      @my_study_path.program_revision_code = params["study_path"]["program_revision_code"]
      @my_study_path.title = params["study_path"]["title"]
      @my_study_path.save
    end
    redirect_to "/admins/#{@my_study_path.id}"
	end

  def long_cuts (grades)
    grades.each_with_index do |grade, index|
        if(grade[:subj].include? "Comm")
           grade[:subj] = grade[:subj].insert(4, ".")
        end
        if(grade[:subj].include? "Hum")
           grade[:subj] = grade[:subj].insert(3, ".")
        end
        if(grade[:subj].include? "Lit")
           grade[:subj] = grade[:subj].insert(3, ".")
        end
        if(grade[:subj].include? "Soc")
            grade[:subj] = grade[:subj].insert(grade[:subj].index("Soc")+3, "ial")
        end
        if(grade[:subj].include? "Sci")
           grade[:subj] = grade[:subj].insert(grade[:subj].index("Sci")+3, "ence")
        end
        if(grade[:subj].include? "Envi")
           grade[:subj] = grade[:subj].insert(grade[:subj].index("Envi")+4, "ronmental")
        end
        if(grade[:subj].include? "Philo")
           grade[:subj] = grade[:subj].insert(grade[:subj].index("Philo")+5, "sophy")
        end
        if(grade[:subj].include? "Bio")
           grade[:subj] = grade[:subj].insert(grade[:subj].index("Bio")+3, "logy")
        end
        if(grade[:subj].include? "Hist")
           grade[:subj] = grade[:subj].insert(grade[:subj].index("Hist")+4, "ory")
           
           if(grade[:subj].include? "I")
              grade[:subj] = grade[:subj].gsub("I", "1")
           end
           if(grade[:subj].include? "II")
              grade[:subj] = grade[:subj].gsub("II", "2")
           end
        end
      end
    return grades
  end
	def update_subjects
		@title = 'SPTS - Update Subjects'
		@year = params['year']
		@semester = params['semester']
    @id = params['id']
    @subject_id = params['subject_id']
    @study_path = StudyPath.find_by id: @id
    
		@current = StudyPathSubject.where(["study_path_id = ? and year = ? and semester = ?", @id, @year, @semester])
		@current_subjects = Array.new
		@current.each do |curr|
       if(curr.subject_id.nil?)
          if curr.rgep.nil?
          else
            @current_subjects << (RgepCluster.find_by id: curr.rgep)
          end
       else
         @current_subjects << Subject.find(curr.subject_id)
       end  
		end
    
    @study_path_subjects = StudyPathSubject.where study_path_id: @id
    if @study_path.subjects.count == 0
       @subjects = Subject.group(:subject_id)
    else
      @subjects = Subject.group(:subject_id, :id)
      
      @study_path_subjects.each do |s|
        @subjects = (@subjects.where.not id: s.subject_id).group(:subject_id)
      end
    end
	end

	def add_subject
		@study_path_id = params['study_path']
		@subject_id = params['subject']
		@year = params['year']
		@semester = params['semester']

		@study_path_subject = StudyPathSubject.create(study_path_id: @study_path_id, subject_id: @subject_id, year: @year, semester: @semester)
		redirect_to '/study_path/' + @study_path_id + '/update_subjects?semester=' + @semester + '&year=' + @year+ '&subject_id=' + @subject_id
	end
  def remove_subject
		@study_path_id = params['study_path']
		@subject_id = params['subject']
		@year = params['year']
		@semester = params['semester']
    
    if(@subject_id.nil?)
      @study_path_subject = StudyPathSubject.find_by subject_id: @subject_id 
      @study_path_subject.destroy 
      redirect_to '/study_path/' + @study_path_id + '/update_subjects?semester=' + @semester + '&year=' + @year+ '&subject_id=' + @subject_id
	
    end
  end
end
