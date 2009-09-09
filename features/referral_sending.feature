Feature: Referral sending
  In order to share a site with my friends
  As a user
  I want send them an email with a link and some text

	Scenario: User can send friends email
	  Given I am signed up and signed in as "email@person.com/password"
	  When I go to the new referral page
	  Then outcome



