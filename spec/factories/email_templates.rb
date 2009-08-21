Factory.define :email_template do |e|
  e.name { Factory.next(:name) }
  e.subject 'some important news'
  e.body 'booyakasha'
end
