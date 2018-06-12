Feature: Student Grade navigation

	As a student
	I want to be able to navigate the grades
	So that I can see the summary of my grades
	
Scenario: Student navigates grades
  Given I login as "student"
	And I fill in "student_number" with "201510778"
	And I fill in "Password" with "201510778"
	And I click "Login"
	Then I should see my dashboard
	Given I am on the grades
	Then I should be able to see a table of my grades