Given /^Referrals have been enabled in the site settings$/ do
  SiteSetting.first.update_attributes(:referrals => true)
end
