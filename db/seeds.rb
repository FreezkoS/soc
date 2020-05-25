# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)
User.create!(name: "Egor Kot", email: "egor.uxanov.97@mail.ru", password:"12345AB", password_confirmation: "12345AB", admin: true, activated: true, activated_at: Time.zone.now)
99.times do |n|
   name = Faker::Name.name
   email = "example-#{n+1}@railstutorial.org"
   password = "password"
   User.create!(name: name,
                email: email,
                password:              password,
                password_confirmation: password,
                activated: true,
                activated_at: Time.zone.now)
end

user = User.order(:created_at)
50.times do
    content = Faker::Lorem.sentence(5)
    user.each { |user| user.microposts.create!(content: content) }
end