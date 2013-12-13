namespace :db do
  desc "Fill database with sample data"
  task populate: :environment do
    admin = User.create!(name: "Example User",
                        email: "example@railstutorial.org",
                        password: "foobar",
                        password_confirmation: "foobar",
                        admin: true)
    99.times do |n|
      name = Faker::Name.name
      email = "eample-#{n + 1}@railstutorial.org"
      password = "password"
      User.create!(name: name,
                  email: email,
                  password: password,
                  password_confirmation: password)
    end

    users = User.all(limit: 6)
    users.each do |user|
      50.times do |n|
        content = Faker::Lorem.sentence(5)
        created_at = rand(1000).hours.ago
        user.micropost.create!(content: content,
                              created_at: created_at)
      end
    end
  end
end