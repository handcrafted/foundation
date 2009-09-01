Factory.define :valid_referral, :class => Referral do |r|
  r.association :referrer, :factory => :valid_user
  r.email_address { Factory.next(:email) }
  r.email_text "Check out this website!"
end

Factory.define :invalid_referral, :class => Referral do |r|
  r.association :referrer, :factory => :valid_user
  r.email_address "invalid"
end