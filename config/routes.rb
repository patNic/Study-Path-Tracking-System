Rails.application.routes.draw do
  get 'spts/index'
  get 'spts/about', :to => 'spts#about'
  get 'spts/developers_portal', :to => 'spts#developers_portal'
  post 'spts/student_login', :to => 'spts#student_login'
  post 'spts/faculty_login', :to => 'spts#faculty_login'
  delete 'spts/logout', :to => 'spts#logout'
  root 'spts#index'

  get 'student/dashboard', :to => 'students#dashboard'
  get 'student/charts', :to => 'students#charts'
  get 'student/grades', :to => 'students#grades'
  get 'student/unitsEarned', :to => 'students#unitsEarned'
  get 'student/unitsToGo', :to => 'students#unitsToGo'
  
  resources :admins
  get 'admin/dashboard', :to => 'admins#dashboard'
  post 'admin/dashboard', :to => 'admins#dashboard'
  get 'admin/add_study_path', :to => 'admins#add_study_path'
  get 'admin/view_study_path', :to => 'admins#view_study_path'
  get 'admin/remove_study_path', :to => 'admins#remove_study_path'
  get 'admin/:id/delete_certain_study_path', :to => 'admins#delete_certain_study_path'
  
  resources :study_paths
  get 'study_path/:id/remove_subject', :to => 'study_paths#remove_subject', as: 'remove_subject'
  get 'study_path/:id/add_subject', :to => 'study_paths#add_subject', as: 'add_subject'
  get 'study_path/:id/update_subjects', :to => 'study_paths#update_subjects', as: 'update_subjects'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end