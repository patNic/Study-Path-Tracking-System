Given("I am on the landing page") do
  visit '/'
end

Then("I should see the {string}") do |string|
   expect(page).to have_selector("input", :count => 6)
end

Given("I login as {string}") do |string|
  visit '/'
end

Given("I fill in \"student_number\" with {string}") do |string|
    within ("#student_login") do
      fill_in "spts_user", with: "#{string}"
    end
end

Given("I fill in \"Password\" with {string}") do |string|
    within ("#student_login") do
      fill_in "spts_password", with: "#{string}"
    end
end

Given("I click {string}") do |string|
  within ("#student_login") do
      click_button "#{string}"
   end
end

Then("I should see my dashboard") do
  expect(page).to have_content("Dashboard")
end

Then("I should see the login page") do
   expect(page).to have_selector("input", :count => 6)
end

Given("I am on the {string}") do |string|
  expect(page).to have_content("Dashboard")
end

Then("I should be able to see button {string}") do |string|
  expect(page).to have_content("#{string}")
end

Given("I am on the grades") do
  visit('/student/grades')
end

Then("I should be able to see a table of my grades") do
  expect(page).to have_css 'table'
  
  expect(page).to have_text 'Subject'
  expect(page).to have_text 'Units'
  expect(page).to have_text 'Final Grade'
  expect(page).to have_text 'Remarks'
  expect(page).to have_text 'Completion Grade'
end