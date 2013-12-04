FactoryGirl.define do
  factory :user do
    name  'Jacob Levine'
    email 'test@test.com'
    password 'testpw'
    password_confirmation 'testpw'
  end
end