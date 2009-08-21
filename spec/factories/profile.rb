Factory.define :profile do |f|
  f.email { Factory.next(:email) }
  f.first_name 'Joe'
  f.last_name 'Sixpack'
end
