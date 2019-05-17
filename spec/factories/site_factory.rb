FactoryBot.define do
  factory :site do
    sequence(:id)
    sequence(:code, &:to_s)
    location_name { 'Main Site' }
  end
end
