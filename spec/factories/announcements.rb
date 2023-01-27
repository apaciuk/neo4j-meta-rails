FactoryBot.define do
  factory :announcement do
    published_at { "2023-01-27 18:31:42" }
    announcement_type { "MyString" }
    name { "MyString" }
    description { "MyText" }
  end
end
