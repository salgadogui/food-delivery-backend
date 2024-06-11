FactoryBot.define do
  factory :store do
    name { "Test Store" }
    user_id { 2 } 
    created_at { Time.now }
    updated_at { Time.now }
  end
end
