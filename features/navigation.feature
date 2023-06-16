Feature: Links are working and pages are displayed correctly

  Scenario: User should be able to see the initial homepage correctly
    When I visit app's root URL
    Then I should see the homepage

  Scenario: User should be able to see the homepage with existing input data correctly
    Given there is pre-existing input data
    When I visit app's root URL
    Then I should see the homepage
    And I should see the Lecturers relation

  Scenario: User should be able to provide program text as a URL param
    Given there is pre-existing input data
    When I visit app's root URL with the program param set to "Students[name] -> Res"
    Then I should see the homepage with "Students[name] -> Res" program

  Scenario: User should be able to clear the program text
    Given there is pre-existing input data
    And I visit app's root URL with the program param set to "Students[name] -> Res"
    When I click on Clear link
    Then I should see the homepage

  Scenario: User should be able to navidate to empty Input data page
    Given I visit app's root URL
    When I click on Edit link
    Then I should be on Input data page

  Scenario: User should be able to navigate to Input data page with existing data
    Given there is pre-existing input data
    And I visit app's root URL
    When I click on Edit link
    Then I should be on Input data page
    And I should see a section with the Lecturers relation

  Scenario: User should be able to navigate to Add new relation page
    Given I visit app's root URL
    And I click on Edit link
    When I click on Add new relation link
    Then I should be on Add new relation page

  Scenario: User should be able to navigate to Edit relation page
    Given there is pre-existing input data
    And I visit app's root URL
    And I click on Edit link
    When I click on Edit link next to Lecturers relation name
    Then I should be on Edit Lecturers relation page

  Scenario: User should be able to navigate to Drop relation page
    Given there is pre-existing input data
    And I visit app's root URL
    And I click on Edit link
    When I click on Drop link next to Lecturers relation name
    Then I should be on Drop Lecturers relation page
    And I should see the Lecturers relation
