Factory.define :invite do |u|
  u.email { Factory.next(:email) }
  u.association :inviter, :factory => :valid_user
end
