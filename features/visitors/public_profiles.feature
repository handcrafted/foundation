Feature: Public profiles
  In order to gauge the value of a community
  As a visitor
  I want to see public profiles
  
  Scenario: Visitor visits a profile page when public profiles are enabled
    Given site settings have been enabled for "public_profiles"
    And a user exists with an email of "josh@gethandcrafted.com"
    When I go to valid_user's profile page
    Then I should see "josh@gethandcrafted.com"
  
  Scenario: Visitor visits a profile page when public profiles are disabled
    Given site settings have been disabled for "public_profiles"
    And a user exists with an email of "josh@gethandcrafted.com"
    When I go to valid_user's profile page
    Then I should see "You must be signed in to access this page"
  
  
  
  
  

  
