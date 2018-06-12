class RecordsController < ApplicationController

  @stud_info
  @schedule
  @@id 
  @@pw 
  def index 
  end

  def home
      a = Mechanize.new
    
      stud_id  = params[:student_number]
      password = params[:password] 
      
      if stud_id != nil and password != nil
         @@id = params[:student_number]
         @@pw = params[:password]           
       
      elsif stud_id == nil and password == nil
         stud_id  = @@id
         password = @@pw
      end
      
      e = "Student ID|:|Name|Degree Level|Degree Program|Year Level|Scholarship"
      
        String url = 'http://crs.upv.edu.ph/tacloban/student/loginAuthenticate.jsp?studentIDYear=&studentIDNumber='+stud_id+'&password='+password
        
        login = a.get(url)
        @stud_info = (login.search(".//td[@class='labelleftbrown8B']").text).to_s
        @stud_info =  @stud_info.gsub(/\s+/, " ")
   
        @stud_info.gsub!(/#{e}/, '@')
        d = @stud_info.split("@")
        info = Array.new
        d.each do |w|
            if !(w.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '') == "")
              info << w.gsub(/\A[[:space:]]+|[[:space:]]+\z/, '')
            end
        end              
        
        @stud_info = info
        
        String url = 'http://crs.upv.edu.ph/tacloban/student/loginAuthenticate.jsp?studentIDYear=&studentIDNumber='+stud_id+'&password='+password
        
        login = a.get(url)
        
        String n = 'http://crs.upv.edu.ph/tacloban/student/gradesView.jsp?seiaccesstype=studentmenu&studentID='+stud_id

        g = a.get(n)


        String o  = 'http://crs.upv.edu.ph/tacloban/student/mySchedule.jsp?studentID='+stud_id+'&semID=2&ayID=38'
        h = a.get(o)
        headers = [:num, :subj, :section, :units, :schedule]
        rows= []
        h.search(".//tr[@class='recordentry']").each_with_index do |elem, ind|
            rows[ind] = {}
            elem.xpath('td').each_with_index do |l, index|
              i = l.text.to_s
              i = i.gsub(/\s+/, " ") 
              rows[ind][headers[index]] = i
            end
        end
        rows2= []
        h.search(".//tr[@class='recordentrylight']").each_with_index do |elem, ind|
        rows2[ind] = {}
          elem.xpath('td').each_with_index do |l, index|
            i = l.text.to_s
            i = i.gsub(/\s+/, " ") 
            rows2[ind][headers[index]] = i
          end
        end

        rows1 = rows + rows2
        @schedule = rows1.sort_by { |hsh| hsh[:num] }
         
        if(login.uri.to_s.include?("errorMsg"))
          flash[:error] = "Your credentials do not match our records!"
          redirect_to "/"
        end
  end
  
  def personalProfile
  end
  
  def charts
  end
  
  def grades
  end
  
  def schedule
  end
  
  def studyplan
  end
  
  def incurred5
  end
end
