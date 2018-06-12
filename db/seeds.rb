# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

require 'rubygems'
require 'mechanize'
require 'nokogiri'

agent = Mechanize.new
subjects_url = 'http://crs.upv.edu.ph/views/subjectOfferings.jsp?view=subjects&find=&unitID=null&campus=4&degreelevel=U'
current_page = agent.get subjects_url
html_doc = Nokogiri::HTML current_page.body
 
 subjects = []
 subject_headers = [:code, :title, :pre_req, :description, :rgep_cluster, :credit, :degree_level, :offering_unit_campus]
 current_page.search(".//tr[@class='recordentry' or @class='recordentrylight']").each_with_index do |elem, ind|
    subjects[ind] = {}
    counter = 0
    subjects[ind][subject_headers[0]] = elem.xpath('td[2]/text()').to_s.gsub(/\s+/, " ").gsub(/\u00A0/, "")
    elem.xpath('td').each do |a|
     count = 0
     ii = a.text.to_s
     ii = ii.gsub(/\s+/, " ").gsub(/\u00A0/, "")
     
     if counter == 1
         a.xpath("i").each do |b|
          b.search("font[@class='labelleftgreen7B']").each do |c|
            i = c.text.to_s
            i = i.gsub(/\s+/, " ").gsub(/\u00A0/, "")
            count += 1
            if(count == 2 && i.length > 40)
              count+=1
            end
            if(count == 3 && i.include?("GE ("))
              count+=1
            end
              subjects[ind][subject_headers[count]] = i  
          end
        end
     elsif counter == 2
         subjects[ind][subject_headers[5]] = ii
     elsif counter == 3
         subjects[ind][subject_headers[6]] = ii
     elsif counter == 4
         subjects[ind][subject_headers[7]] = ii
     end
     counter += 1
    end
  end
  
 subjects[170][:pre_req]= subjects[170][:description]
 subjects[170][:description] = " "
 subjects[36][:pre_req]= subjects[36][:description]
 subjects[36][:description] = " "
subjects.each_with_index do |c, ind|
  subjects[ind][:offering_unit_campus]= subjects[ind][:offering_unit_campus].gsub("- Tacloban City", "").gsub(" ", "")
end
division_names = ["MGT", "NSMD", "HUM", "SOCSCI"]

degrees = ["BS IN ACCOUNTANCY", "BS IN MANAGEMENT", "BS (BIOLOGY)",  "BS IN COMPUTER SCIENCE","BA (SOCIAL SCIENCE) ECONOMICS",
"BA (SOCIAL SCIENCE) POLITICAL SCIENCE","BA (PSYCHOLOGY)","BA (COMMUNICATION ARTS)"]
degree_code = ["BSA", "BSM", "BS-Bio", "BSCS", "BA-Econ", "BA-PolSci", "BA-Psych", "BACA"]

#Add the divisions
division_names.each do |div| 
  Division.create(name: div)
end

degrees.each_with_index do |degree, index| 
  if index == 0
    Degree.create(division_id: (Division.find_by name: "MGT").id, code: degree_code[index], name: degree, years: 4)
  elsif index == 1
    Degree.create(division_id: (Division.find_by name: "MGT").id, code: degree_code[index], name: degree, years: 5)
  elsif index == 2 or index == 3
    Degree.create(division_id: (Division.find_by name: "NSMD").id, code: degree_code[index], name: degree, years: 4)
  elsif index == 4 or index == 5 or index == 6
    Degree.create(division_id: (Division.find_by name: "SOCSCI").id, code: degree_code[index], name: degree, years: 4)
  elsif index == 7
    Degree.create(division_id: (Division.find_by name: "HUM").id, code: degree_code[index], name: degree, years: 4)
  end
end

subjects.each do |s|
  FakeSubject.create subject_code: s[:code].strip
end

subjects.each do |subj|
  units = subj[:credit].to_i
  isGE = false
  if (subj[:rgep_cluster].nil?)
  else
    if subj[:rgep_cluster].include? "GE"
      if(RgepCluster.where(name: subj[:rgep_cluster].strip).length == 0)
         RgepCluster.create(name: subj[:rgep_cluster].strip, units: 3.0) 
       end
      isGE = true
    end
  end
  
  if subj[:pre_req] == " " or subj[:pre_req].nil?
    puts "RGEP #{subj[:rgep_cluster]}"
    Subject.create(division_id: (Division.find_by name: subj[:offering_unit_campus]).id, fake_subject_id: nil,subject_id: subj[:code].strip, name: subj[:title], description: subj[:description],
    pre_req: subj[:pre_req] ,units: units,isGe: isGE, rgep: subj[:rgep_cluster])
  else
    pre_req = subj[:pre_req].split(",")
    pre_req.each do |p|
      p = p.strip
      if (FakeSubject.find_by subject_code: p).nil?
        puts "RGEP #{subj[:rgep_cluster]}"
        Subject.create(division_id: (Division.find_by name: subj[:offering_unit_campus]).id, fake_subject_id: nil,subject_id: subj[:code].strip, name: subj[:title], description: subj[:description],
        units: units,isGe: isGE, rgep: subj[:rgep_cluster])
      else
        puts "RGEP #{subj[:rgep_cluster]}"
        Subject.create(division_id: (Division.find_by name: subj[:offering_unit_campus]).id, fake_subject_id: (FakeSubject.find_by subject_code: p).id,subject_id: subj[:code].strip, name: subj[:title], description: subj[:description],
        pre_req: subj[:pre_req], units: units,isGe: isGE, rgep: subj[:rgep_cluster])
      end
    end
  end
end

  #Add Elective, PE 2, and NSTP to rgepcluster
  RgepCluster.create(name: "PE 2", units: 2.0)
  RgepCluster.create(name: "NSTP", units: 3.0)
  RgepCluster.create(name: "Elective", units: 3.0)

  studyPath = Hash.new
  ge_ah_id = RgepCluster.where(name: "GE (AH)").pluck(:id).first
  ge_mst_id = RgepCluster.where(name: "GE (MST)").pluck(:id).first
  ge_ssp_id = RgepCluster.where(name: "GE (SSP)").pluck(:id).first
  ge_pe_2_id = RgepCluster.where(name: "PE 2").pluck(:id).first
  ge_nstp_id = RgepCluster.where(name: "NSTP").pluck(:id).first
  elec_id = RgepCluster.where(name: "Elective").pluck(:id).first

  rgep_code = {ah: ge_ah_id, mst: ge_mst_id, ssp: ge_ssp_id, pe2: ge_pe_2_id, nstp: ge_nstp_id, elective: elec_id}

  #BSCS major subjects
  all_major_subjects = [[{subject_id: "CMSC 11", name: "Introduction to Computer Science", pre_req: "Math 17", units: 3.0, isGe: false},
              {subject_id:  "Math 17", name: "Algebra and Trigonometry", pre_req: "1 yr. of HS Algebra", units: 5.0, isGe: false}, 
              {subject_id:  "P.E. 1", name:  "Foundation of Physical Fitness", pre_req:  nil, units: 2.0, isGe: true}, 
              {subject_id:  "CMSC 21", name: "Fundamentals of Programming", pre_req:  "CMSC 11", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 56", name: "Discrete Mathematical Structures in Computer Science 1", pre_req:  "Math 17, CMSC 11", units: 3.0, isGe: false}, 
              {subject_id:  "Math 53", name: "Elementary Analysis I", pre_req:  "Math 17 or equivalent",  units: 5.0, isGe: false}, 
              {subject_id:  "CMSC 22", name: "Fundamentals of Object-oriented Programming", pre_req: "CMSC 21",  units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 57", name: "Discrete Mathematical Structures in Computer Science 2", pre_req: "CMSC 56", units: 3.0, isGe: false}, 
              {subject_id:  "Physics 51", name: "General Physics 1", pre_req:  "Math 17 or equivalent", units: 3.0, isGe: false}, 
              {subject_id:  "Physics 51.1", name: "General Physics 1 Laboratory", pre_req: "Physics 51", units: 1.0, isGe: false}, 
              {subject_id:  "Math 54", name: "Elementary Analysis II", pre_req:  "Math 53", units: 5.0, isGe: false}, 
              {subject_id:  "CMSC 123", name: "Data Structures", pre_req: "CMSC 21, CMSC 57", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 130", name: "Logic Design and Digital Computer Circuits", pre_req: "CMSC 11", units: 3.0, isGe: false}, 
              {subject_id:  "Physics 52", name: "General Physics II", pre_req: "Physics 51", units: 3.0, isGe: false}, 
              {subject_id:  "Physics 52.1", name: "General Physics II, Lab", pre_req: "Physics 52", units: 1.0, isGe: false}, 
              {subject_id:  "Math 55", name: "Elementary Analysis III", pre_req: "Math 54", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 127", name: "File Processing and Database System", pre_req: "CMSC 123", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 131", name: "Intro in Computer Organization and Machine Level", pre_req: "CMSC 21, CMSC 130", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 124", name: "Automata and Language Theory", pre_req: "CMSC 57", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 142", name: "Designs and Analysis of Algorithms", pre_req: "CMSC 123", units: 3.0, isGe: false}, 
              {subject_id:  "Stat 105", name: "Introduction to Statistical Analysis", pre_req: "Math 17", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 141", name: "Design and Implementation of Programming Languages", pre_req: "CMSC 123, CMSC 124", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 125", name: "Operating Systems", pre_req: "CMSC 123, CMSC 131", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 128", name: "Intro to Software Engineering", pre_req: "CMSC 123", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 195", name: "Practicum", pre_req: "Consent of Instructor", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 121", name: "Internet Technologies", pre_req: "CMSC 22", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 132", name: "Computer Architecture", pre_req: "CMSC 131", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 198.1", name:  "Special Problem 1", pre_req: "Senior Standing", units: 3.0, isGe: false}, 
              {subject_id:  "PI 100", name: "The Life and Works of Rizal", pre_req: "Senior Standing", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 135", name: "Data Communication and Networking", pre_req: "CMSC 125", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 198.2", name: "Special Problem 2", pre_req: "CMSC 198.1", units: 3.0, isGe: false}, 
              {subject_id:  "CMSC 196", name: "Undergraduate Seminar", pre_req: "Senior Standing", units: 1.0, isGe: false}]]

  # Pre-create prerequisite subjects not already in FakeSubjects table
  all_major_subjects.each do |course|
    course.each do |subj|
      if(FakeSubject.where(subject_code: subj[:pre_req]).pluck(:id).first == nil)
        FakeSubject.create(subject_code: subj[:pre_req])
      end   
    end
  end                

  # create the missing Subjects
  all_major_subjects.each do |course|
    course.each do |subj|
      if(Subject.where(subject_id: subj[:subject_id]).pluck(:id).first == nil)
          Subject.create(division_id: (Division.find_by name: "NSMD").id, 
                          fake_subject_id: (FakeSubject.find_by subject_code: subj[:pre_req]).id,
                          subject_id: subj[:subject_id].strip, name: subj[:name], 
                          pre_req: subj[:pre_req], 
                          units: subj[:units],
                          isGe: subj[:isGE])
      end   
    end
  end
  
  bscs_majors = {
                 pe1: Subject.where(subject_id: "P.E. 1").pluck(:id).first,
                 math_17: Subject.where(subject_id: "Math 17").pluck(:id).first,
                 cmsc_11: Subject.where(subject_id: "CMSC 11").pluck(:id).first,
                 cmsc_21: Subject.where(subject_id: "CMSC 21").pluck(:id).first,
                 cmsc_56: Subject.where(subject_id: "CMSC 56").pluck(:id).first,
                 math_53: Subject.where(subject_id: "Math 53").pluck(:id).first,
                 cmsc_57: Subject.where(subject_id: "CMSC 57").pluck(:id).first,
                 cmsc_22: Subject.where(subject_id: "CMSC 22").pluck(:id).first,
                 physics_51: Subject.where(subject_id: "Physics 51").pluck(:id).first,
                 physics_51_1: Subject.where(subject_id: "Physics 51.1").pluck(:id).first,
                 math_54: Subject.where(subject_id: "Math 54").pluck(:id).first,
                 cmsc_123: Subject.where(subject_id: "CMSC 123").pluck(:id).first,
                 cmsc_130: Subject.where(subject_id: "CMSC 130").pluck(:id).first,
                 physics_52: Subject.where(subject_id: "Physics 52").pluck(:id).first,
                 physics_52_1: Subject.where(subject_id: "Physics 52.1").pluck(:id).first,
                 math_55:Subject.where(subject_id: "Math 55").pluck(:id).first,
                 cmsc_127:Subject.where(subject_id: "CMSC 127").pluck(:id).first,
                 cmsc_131: Subject.where(subject_id: "CMSC 131").pluck(:id).first,
                 cmsc_124: Subject.where(subject_id: "CMSC 124").pluck(:id).first,
                 cmsc_142: Subject.where(subject_id: "CMSC 142").pluck(:id).first,
                 stat_105: Subject.where(subject_id: "Stat 105").pluck(:id).first,
                 cmsc_141: Subject.where(subject_id: "CMSC 141").pluck(:id).first,
                 cmsc_125: Subject.where(subject_id: "CMSC 125").pluck(:id).first,
                 cmsc_128: Subject.where(subject_id: "CMSC 128").pluck(:id).first,
                 cmsc_195: Subject.where(subject_id: "CMSC 195").pluck(:id).first,
                 cmsc_121: Subject.where(subject_id: "CMSC 121").pluck(:id).first,
                 cmsc_132: Subject.where(subject_id: "CMSC 132").pluck(:id).first,
                 cmsc_198_1: Subject.where(subject_id: "CMSC 198.1").pluck(:id).first,
                 pi_100: Subject.where(subject_id: "PI 100").pluck(:id).first,
                 cmsc_135: Subject.where(subject_id: "CMSC 135").pluck(:id).first,
                 cmsc_198_2: Subject.where(subject_id: "CMSC 198.2").pluck(:id).first,
                 cmsc_196: Subject.where(subject_id: "CMSC 196").pluck(:id).first
                 }

  prog_rev_code = [nil, nil, nil, "426002003", nil, nil, nil, nil]
  degree_code = ["BSA", "BSM", "BS-Bio", "BSCS", "BA-Econ", "BA-PolSci", "BA-Psych", "BACA"]

  #Populate Study Path for each degree
  for i in 0...degree_code.length do 
    degree_id = Degree.where(code: degree_code[i]).distinct.pluck(:id).join(",")
    StudyPath.create(degree_id: degree_id, program_revision_code: prog_rev_code[i], title: "#{degree_code[i]}_sp")
  end

  #BSCS study path
  studyPath = [{:year => :"First", :sem => :"First", 
                          :subjects => [{code: nil, rgep: rgep_code[:ah]}, 
                                        {code: nil, rgep: rgep_code[:ssp]}, 
                                        {code: nil, rgep: rgep_code[:mst]},                                         
                                        {code: nil, rgep: rgep_code[:nstp]},
                                        {code: bscs_majors[:pe1], rgep: nil},  
                                        {code: bscs_majors[:math_17], rgep: nil},
                                        {code: bscs_majors[:cmsc_11], rgep: nil}
                                        ]},
                {:year => :"First", :sem => :"Second", 
                          :subjects => [{code: nil, rgep: rgep_code[:ah]}, 
                                        {code: nil, rgep: rgep_code[:ssp]}, 
                                        {code: nil, rgep: rgep_code[:mst]}, 
                                        {code: nil, rgep: rgep_code[:pe2]}, 
                                        {code: nil, rgep: rgep_code[:nstp]}, 
                                        {code: bscs_majors[:cmsc_21], rgep: nil},
                                        {code: bscs_majors[:cmsc_56], rgep: nil},
                                        {code: bscs_majors[:math_53], rgep: nil},
                                        ]},
                {:year => :"Second", :sem => :"First", 
                          :subjects => [{code: nil, rgep: rgep_code[:ah]},                                         
                                        {code: nil, rgep: rgep_code[:ssp]},
                                        {code: nil, rgep: rgep_code[:pe2]}, 
                                        {code: bscs_majors[:cmsc_22], rgep: nil},
                                        {code: bscs_majors[:cmsc_57], rgep: nil},
                                        {code: bscs_majors[:physics_51], rgep: nil},
                                        {code: bscs_majors[:physics_51_1], rgep: nil},
                                        {code: bscs_majors[:math_54], rgep: nil}
                                        ]},
                {:year => :"Second", :sem => :"Second", 
                          :subjects => [{code: nil, rgep: rgep_code[:ah]},  
                                        {code: nil, rgep: rgep_code[:mst]},   
                                        {code: nil, rgep: rgep_code[:pe2]},   
                                        {code: bscs_majors[:cmsc_123], rgep: nil},
                                        {code: bscs_majors[:cmsc_130], rgep: nil},
                                        {code: bscs_majors[:physics_52], rgep: nil},
                                        {code: bscs_majors[:physics_52_1], rgep: nil},
                                        {code: bscs_majors[:math_55], rgep: nil},
                                        ]},
                {:year => :"Third", :sem => :"First", 
                          :subjects => [{code: nil, rgep: rgep_code[:ah]}, 
                                        {code: nil, rgep: rgep_code[:ssp]},  
                                        {code: bscs_majors[:cmsc_127], rgep: nil},
                                        {code: bscs_majors[:cmsc_131], rgep: nil},
                                        {code: bscs_majors[:cmsc_124], rgep: nil},
                                        {code: bscs_majors[:cmsc_142], rgep: nil},
                                        {code: bscs_majors[:stat_105], rgep: nil}
                                        ]},
                {:year => :"Third", :sem => :"Second", 
                          :subjects => [{code: nil, rgep: rgep_code[:ssp]},                                         
                                        {code: nil, rgep: rgep_code[:elective]},
                                        {code: nil, rgep: rgep_code[:elective]}, 
                                        {code: bscs_majors[:cmsc_141], rgep: nil},
                                        {code: bscs_majors[:cmsc_125], rgep: nil},
                                        {code: bscs_majors[:cmsc_128], rgep: nil}
                                        ]},
                {:year => :"Third", :sem => :"Summer", 
                          :subjects => [{code: bscs_majors[:cmsc_195], rgep: nil}]},                       
                {:year => :"Fourth", :sem => :"First",  
                          :subjects => [{code: nil, rgep: rgep_code[:mst]}, 
                                        {code: nil, rgep: rgep_code[:ah]}, 
                                        {code: nil, rgep: rgep_code[:ssp]},                                                                                 
                                        {code: bscs_majors[:cmsc_121], rgep: nil},
                                        {code: bscs_majors[:cmsc_132], rgep: nil},
                                        {code: bscs_majors[:cmsc_198_1], rgep: nil}
                                        ]},
                {:year => :"Fourth", :sem => :"Second", 
                          :subjects => [{code: nil, rgep: rgep_code[:elective]}, 
                                        {code: nil, rgep: rgep_code[:elective]}, 
                                        {code: bscs_majors[:cmsc_135], rgep: nil}, 
                                        {code: bscs_majors[:cmsc_198_2], rgep: nil},
                                        {code: bscs_majors[:cmsc_196], rgep: nil},
                                        {code: bscs_majors[:pi_100], rgep: nil}
                                        ]}
                      ] 

  degree_id = Degree.where(code: degree_code[3]).pluck(:id)
  study_path_id = StudyPath.where(degree_id: degree_id).pluck(:id).first

  studyPath.each_with_index do |study_path, index|
    study_path[:subjects].each do |subj|
      StudyPathSubject.create(study_path_id: study_path_id, subject_id: subj[:code], rgep: subj[:rgep], year: study_path[:year], semester: study_path[:sem])
    end
  end

Subject.create(division_id: 2, fake_subject_id: nil, subject_id: "Biology 20", name: "Living with Microbes in Sickness and in Health",
units: 3, isGe: true, rgep: "GE (MST)")
Subject.create(division_id: 2, fake_subject_id: nil, subject_id: "CMSC 197", name: "Trading",units: 3, isGe: true, rgep: "Elective")
RgepCluster.create name: "PE 1", units: 2
StudyPathSubject.create study_path_id: 4, subject_id: nil, rgep: 7, year: "First", semester: "First"

Admin.create(user_name: "jd_ultra_man", password: "ultra_power")