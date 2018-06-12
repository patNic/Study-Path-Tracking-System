Feature: User login
	As a user
	I should be able to login to the website using my crs login credentials
	So that I can view my dashboard

Scenario: User visits the site
	Given I am on the landing page
	Then I should see the "Login Form"
  
Scenario: Student logs in successfully
	Given I login as "student"
	And I fill in "student_number" with "201510778"
	And I fill in "Password" with "201510778"
	And I click "Login"
	Then I should see my dashboard
  
Scenario: Student logs in with wrong credentials
	Given I login as "student"
	And I fill in "student_number" with "201510778"
	And I fill in "Password" with "201510"
	And I click "Login"
	Then I should see the login page
