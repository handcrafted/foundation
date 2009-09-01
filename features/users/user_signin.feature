Feature: Sign in
  In order to get access to protected sections of the site
  A user
  Should be able to sign in
  
  
  Scenario: User is not signed up
    Given no user exists with an email of "email@person.com"
    When I go to the sign in page
    And I sign in as "email@person.com/password"
    Then I should see "There is an issue with your credentials."
    And I should be signed out
  
  Scenario: User signs in successfully
    Given I am signed up and confirmed as "email@person.com/password"
    When I go to the sign in page
    And I sign in as "email@person.com/password"
    Then I should see "You have been signed in"
    And I should be signed in
  