Feature: Input data manipulations

  Scenario Outline: User should be able to create an empty relation
    Given I visit app's root URL
    And I navigate to Add new relation page
    And I enter the schema for <relation_name> relation
    When I click submit button
    Then I should be on Input data page
    And I should see a section with the empty <relation_name> relation
    Examples:
      | relation_name     |
      | Students          |
      | Lecturers         |
      | Courses           |
      | CourseEnrollments |

  Scenario Outline: User should be able to create a relation with data
    Given I visit app's root URL
    And I navigate to Add new relation page
    And I enter the schema for <relation_name> relation
    And I enter the data for <relation_name> relation
    When I click submit button
    Then I should be on Input data page
    And I should see a section with the <relation_name> relation
    Examples:
      | relation_name     |
      | Students          |
      | Lecturers         |
      | Courses           |
      | CourseEnrollments |

  Scenario: User should be able to rename an existing relation
    Given there is pre-existing input data
    And I visit app's root URL
    And I navigate to Edit Lecturers relation page
    When I clear the name field
    When I enter "FacultyMembers" into the name field
    And I click submit button
    Then I should be on Input data page
    And I should see the following lines within the FacultyMembers section:
      | line                  |
      | id \| name            |
      | 1  \| Sully Prudhomme |
      | (4 record(s))         |

  Scenario: User should be able to delete all rows from an existing relation
    Given there is pre-existing input data
    And I visit app's root URL
    And I navigate to Edit Students relation page
    When I clear the rows field
    And I click submit button
    Then I should be on Input data page
    And I should see the following lines within the Students section:
      | line                            |
      | id \| name \| date_of_admission |
      | (0 record(s))                   |

  Scenario: User should be able to edit schema of an existing empty relation
    Given there is pre-existing input data
    And I visit app's root URL
    And I delete all data from Students relation
    And I click on Edit link next to Students relation name
    When I enter "email,string" line into the schema field
    And I click submit button
    Then I should be on Input data page
    And I should see the following lines within the Students section:
      | line                                     |
      | id \| name \| date_of_admission \| email |
      | (0 record(s))                            |

  Scenario: User should be able to edit schema & data of an existing relation
    Given there is pre-existing input data
    And I visit app's root URL
    And I delete all data from Students relation
    And I click on Edit link next to Students relation name
    When I enter "email,string" line into the schema field
    And I enter "1,Quentin Tarantino,01.09.1980,tarantino@e.com" line into the rows field
    And I click submit button
    Then I should be on Input data page
    And I should see the following lines within the Students section:
      | line                                                            |
      | id \| name              \| date_of_admission \| email           |
      | 1  \| Quentin Tarantino \| 1980-09-01        \| tarantino@e.com |
      | (1 record(s))                                                   |

  Scenario: User should be able to edit all relation's properties simultaneously
    Given there is pre-existing input data
    And I visit app's root URL
    And I delete all data from Students relation
    And I click on Edit link next to Students relation name
    When I clear the name field
    And I enter "Alumni" into the name field
    When I enter "email,string" line into the schema field
    And I enter "1,Quentin Tarantino,01.09.1980,tarantino@e.com" line into the rows field
    And I click submit button
    Then I should be on Input data page
    And I should see the following lines within the Alumni section:
      | line                                                            |
      | id \| name              \| date_of_admission \| email           |
      | 1  \| Quentin Tarantino \| 1980-09-01        \| tarantino@e.com |
      | (1 record(s))                                                   |

  Scenario: User should be able to drop an empty relation
    Given there is pre-existing input data
    And I visit app's root URL
    And I delete all data from Lecturers relation
    And I click on Drop link next to Lecturers relation name
    When I click submit button
    Then I should be on Input data page
    And I should not see a section with the Lecturers relation

  Scenario: User should be able to drop a non-empty relation
    Given there is pre-existing input data
    And I visit app's root URL
    And I navigate to Drop Courses relation page
    When I click submit button
    Then I should be on Input data page
    And I should not see a section with the Courses relation

  Scenario Outline: User input on new relation form should be validated
    Given there is pre-existing input data
    And I visit app's root URL
    And I navigate to Add new relation page
    When I enter "<name>" into the name field
    And I enter "<schema>" into the schema field
    And I enter "<rows>" into the rows field
    And I click submit button
    Then I should be on Add new relation page with the following fields pre-filled:
      | name   | schema   | rows   |
      | <name> | <schema> | <rows> |
    And I should see "<error_msg>" error next to the <error_field> field
    Examples:
      | name     | schema          | rows         | error_field | error_msg                                                                   |
      |          | email,string    | john@e.com   | name        | Relation name is required                                                   |
      | Students | email,string    | john@e.com   | name        | Relation with such name already exists                                      |
      | Alumni   |                 |              | schema      | At least one relation attribute is required                                 |
      | Alumni   | email,text      | john@e.com   | schema      | Unknown attribute type(s) provided                                          |
      | Alumni   | randomtext      | john@e.com   | schema      | Failed to parse relation attributes. Please make sure that the CSV is valid |
      | Alumni   | email,string    | 1,john@e.com | rows        | Error in data row 1: 2 columns instead of expected 1                        |
      | Alumni   | id,numeric      | notanumber   | rows        | Error in data row 1: notanumber (id) cannot be parsed into a number         |
      | Alumni   | graduation,date | notadate     | rows        | Error in data row 1: notadate (graduation) cannot be parsed into a date     |

  Scenario Outline: User input on edit relation form should be validated
    Given there is pre-existing input data
    And I visit app's root URL
    And I navigate to Edit Students relation page
    When I clear the name field
    And I enter "<name>" into the name field
    And I enter "<schema>" line into the schema field
    # Adding new line:
    And I enter "" line into the rows field
    And I enter "<rows>" line into the rows field
    And I click submit button
    Then I should be on Edit Students relation page with some of the fields changed
    And I should see "<error_msg>" error next to the <error_field> field
    Examples:
      | name      | schema     | rows                      | error_field | error_msg                                                                   |
      |           |            |                           | name        | Relation name is required                                                   |
      | Lecturers |            |                           | name        | Relation with such name already exists                                      |
      | Students  | email,text |                           | schema      | Unknown attribute type(s) provided                                          |
      | Students  | randomtext |                           | schema      | Failed to parse relation attributes. Please make sure that the CSV is valid |
      | Students  |            | 10,Elvis                  | rows        | Error in data row 10: 2 columns instead of expected 3                       |
      | Students  |            | 10,Elvis,1950-09-01,extra | rows        | Error in data row 10: 4 columns instead of expected 3                       |
      | Students  |            | a,Elvis,1950-09-01        | rows        | Error in data row 10: a (id) cannot be parsed into a number                 |
      | Students  |            | 10,Elvis,meow             | rows        | Error in data row 10: meow (date_of_admission) cannot be parsed into a date |
