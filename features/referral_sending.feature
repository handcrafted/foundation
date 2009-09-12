Feature: Referral sending
  In order to share a site with my friends
  As a user
  I want send them an email with a link and some text

	Scenario: User can send friends email
		Given Referrals have been enabled in the site settings
	  Given I am signed up and signed in as "email@person.com/password"
	  When I go to the new referral page
		And I fill in "Emails" with "joe.sixpack@test.com"
		And I fill in "Email text" with "This is a sample email text"
		And I press "Tell your friends"
	  Then I should see "Your emails have been sent."



