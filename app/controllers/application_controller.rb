class ApplicationController < ActionController::Base
  before_action :authenticate_user!, :except => [:index, :student_login, :faculty_login, :about, :developers_portal]
  protect_from_forgery with: :exception

  protected
    def authenticate_user!
      if session[:user].nil?
        redirect_to '/'
      end
    end

  private
    def access_crs
      @student = Student.new session[:user]['id'], session[:user]['password']
      @student.login
      @basic_info = @student.basic_info
      
      @deg = Degree.find_by id: params["id"]
   
      if(@deg.nil?)
        @deg = Degree.find_by name: (@basic_info['degree_program'].gsub(".",""))
      end
      
      if(@deg.nil?)
        @deg = Degree.find_by name: (params["study_path"]["degree_id"].gsub(".",""))
      end
       @study_path = StudyPath.where(degree_id: @deg.id).take
      
      

      #if @study_path.nil?
      	#@study_path = StudyPath.new
      	#@study_path.id = 0
      #end
    end
end
