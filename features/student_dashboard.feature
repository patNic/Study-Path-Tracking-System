Feature: Student Dashboard navigation
	
	As a student
	I want to be able to navigate the dashboard
	So that I can see the summary of my study path

Scenario: Student navigates dashboard
  Given I login as "student"
	And I fill in "student_number" with "201510778"
	And I fill in "Password" with "201510778"
	And I click "Login"
	Then I should see my dashboard
	Given I am on the "Dashboard"
	Then I should be able to see button "Dashboard"
	And I should be able to see button "Grades"
	And I should be able to see button "Charts"
  And I should be able to see button "Study Plan"