require 'student'

class StudentsController < ApplicationController
  before_action :access_crs

  def dashboard
    @radar_chart_values = charts
    @current_schedule = @student.current_schedule

    @title = "SPTS - Dashboard"
  end

  def charts
    @myGrades = @student.grades

    my_units = Array.new 
    @gwa = ""
    @labels = ""
    @myGrades.each_with_index do |content, i|
      if content[0][:subj].include? "Midyear"
        if i == @myGrades.length - 1
          @labels = @labels[0, @labels.length-2]
        end

        next
      end

      if i == @myGrades.length-1
        @labels << content[0][:subj]
      else
        @labels << content[0][:subj]+ "~"
      end
      my_units << content[(content.length - 1)][:finalGrade]
    end
    
    my_units.each_with_index do |unit, i|
      if i == my_units.length-1
        @gwa << unit[(unit.index("GWA")+4), (unit.length - unit.index("GWA")+2)] 
      else
        @gwa << unit[(unit.index("GWA")+4), (unit.length - unit.index("GWA")+2)]+ ","
      end
    end

    basic_info = @student.basic_info
    
    degree = Degree.find_by name: @basic_info["degree_program"].gsub(".", "")
    study_path_id = StudyPath.find_by degree_id: degree.id
    
    study_path_subjects = StudyPathSubject.where study_path_id: study_path_id.id
    
    @total_AH = study_path_subjects.where rgep: 2
    @total_SSP = study_path_subjects.where rgep: 3
    @total_MST = study_path_subjects.where rgep: 1
    @total_PE2 = (study_path_subjects.where rgep: 4) 
    @total_NSTP = (study_path_subjects.where rgep: 5) 
    @total_PE1 = (study_path_subjects.where rgep: 7)
    @total_elective = (study_path_subjects.where rgep: 6)
    @total_major = (study_path_subjects.where rgep: nil)
    
    @taken_AH = 0
    @taken_SSP = 0
    @taken_MST = 0
    @taken_others = 0
    @taken_elective = 0
    @taken_major = 0
    
   @myGrades = long_cuts(@myGrades)
   @myGrades.each do |grade|
       grade.each do |fs|
              subj = Subject.find_by subject_id: fs[:subj]
                if(!subj.nil?)
                  if(!subj.rgep.nil?)
                   if(subj.rgep.strip == "GE (AH)")
                      @taken_AH = @taken_AH + 1
                    elsif (subj.rgep.strip == "GE (SSP)")
                      @taken_SSP = @taken_SSP + 1
                    elsif (subj.rgep.strip == "GE (MST)")
                      @taken_MST = @taken_MST + 1
                    elsif (subj.rgep.strip == "Elective")
                      @taken_elective = @taken_elective + 1
                    end
                  else
                    @taken_major = @taken_major + 1
                  end
                else
                   if (fs[:subj].include? "P.E." or fs[:subj].include? "PE" or fs[:subj].include? "NSTP")
                      @taken_others = @taken_others + 1
                   end
            end
       end
   end
  
    @title = 'SPTS - Charts'
    
    @total = [@total_AH.length, @total_SSP.length, @total_major.length, @total_PE2.length+@total_PE1.length + @total_NSTP.length,
    @total_elective.length, @total_MST.length]
    @taken = [@taken_AH, @taken_SSP, @taken_major, @taken_others, @taken_elective, @taken_MST]
    
    
    @radar_chart_values = Array.new
    
    @taken.each_with_index do |t, ind|
      @radar_chart_values << (t.to_f/@total[ind])* 100
    end
  
    return @radar_chart_values
  end
  def long_cuts (grades)
    grades.each_with_index do |grade1, index|
        grade1.each do |grade|
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
      end
    return grades
  end
  def grades
    @myGrades = @student.grades
    
    if !params.nil? and params.has_key? "highlight"
      @myGrades.each do |content|
        content.each do |row|
          if row.has_key? :finalGrade or row.has_key? :completionGrade
            if params["highlight"].eql? '5s'
              if row[:finalGrade].eql? ' 5.0 ' or row[:completionGrade].eql? ' 5.0 '
                row[:class] = 'table-danger'
              else
                row[:class] = 'x'
              end
            else
              if row[:finalGrade].eql? ' INC '
                row[:class] = 'table-warning'
              else
                row[:class] = 'x'
              end
            end
          end
        end
      end
    end

    @title = 'SPTS - Grades'
  end

  def unitsEarned
    @total_units = @student.units_earned

    @title = 'SPTS - Units Earned'
  end
  
  def unitsToGo
    @units_remaining = @student.units_remaining - @student.units_earned
    @title = 'SPTS - Units To Go'
  end
end