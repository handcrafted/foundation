Factory.sequence :email do |n|
  "person#{n}@example.com"
end

Factory.sequence :name do |n|
  "name#{n}-#{n}-#{(Time.now + n.seconds).to_s}"
end

