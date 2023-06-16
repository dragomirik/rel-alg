Feature: Relational algebra expressions interpretation
  Background:
    Given there is pre-existing input data
    And I visit app's root URL

  Scenario: User should be able to input an empty program
    When I click submit button
    Then I should see the homepage

  Scenario: User should be able to interpret a one-line program with no new relations
    When I enter "Students[id]" into the program field
    And I click submit button
    Then I should see the homepage with "Students[id]" program

  Scenario: User should be able to see the result of a one-line program interpretation
    When I enter "Students[name] ∪ Lecturers[name] -> Res" into the program field
    And I click submit button
    Then I should see the homepage with "Students[name]" program
    And I should see the following data output:
      | line                  |
      | Res:                  |
      | name                  |
      | John Smith            |
      | Jane Doe              |
      | Annie Ernaux          |
      | Abdulrazak Gurnah     |
      | Louise Glück          |
      | Peter Handke          |
      | Olga Tokarczuk        |
      | Kazuo Ishiguro        |
      | Bob Dylan             |
      | Sully Prudhomme       |
      | Theodor Mommsen       |
      | Bjørnstjerne Bjørnson |
      | Frédéric Mistral      |
      | (13 record(s))        |

  Scenario: User should be able to see the result of a multi-line program interpretation
    When I enter "Courses[lecturer_id=id]Lecturers -> R1" line into the program field
    And I enter "R1[Courses.name,Lecturers.name] -> Res" line into the program field
    And I click submit button
    Then I should see the homepage with "Courses[lecturer_id=id]Lecturers" program
    And I should see the following data output:
      | line                                                    |
      | Res:                                                    |
      | Courses.name                   \| Lecturers.name        |
      | Linear Algebra                 \| Sully Prudhomme       |
      | Analytical Geometry            \| Sully Prudhomme       |
      | Calculus                       \| Sully Prudhomme       |
      | Creative Writing               \| Theodor Mommsen       |
      | Ukrainian Literature           \| Theodor Mommsen       |
      | Music Theory                   \| Bjørnstjerne Bjørnson |
      | Algorithms And Data Structures \| Frédéric Mistral      |
      | (7 record(s))                                           |

  Scenario: User should be able to see an error if the relation with provided name is missing
    When I enter "NonExistentTable[id]" into the program field
    And I click submit button
    Then I should see the homepage with "NonExistentTable[id]" program
    And I should see the following data output:
      | line                                |
      | Unknown relation 'NonExistentTable' |

  Scenario Outline: User should be able to see the interpretation error if the program is invalid
    When I enter "<program>" into the program field
    And I click submit button
    Then I should see the homepage with "<program>" program
    And I should see the following data output:
      | line             |
      | Error on line 1: |
      | <error_msg>      |
  Examples:
    | program                                        | error_msg                                                                                    |
    | Students \ Lecturers                           | Cannot apply DIFFERENCE: relations' attribute types don't match                              |
    | Students ∪ Lecturers                           | Cannot apply UNION: relations' attribute types don't match                                   |
    | Students ∩ Lecturers                           | Cannot apply INTERSECTION: relations' attribute types don't match                            |
    | Students[favorite_color]                       | Cannot apply PROJECTION(favorite_color): relation's attributes do not include favorite_color |
    | Students[id='meow']                            | Cannot apply LIMIT(id='meow'): 'meow' cannot be parsed into a number                         |
    | Students[date_of_admission>0]                  | Cannot apply LIMIT(date_of_admission>0): 0 cannot be parsed into a date                      |
    | Students[id=student_id]Lecturers               | Cannot apply JOIN(id=student_id): second relation's attributes do not include student_id     |
    | Students[id÷id](CourseEnrollments[student_id]) | Cannot apply DIVISION(id/id): second relation's attributes do not include id                 |
