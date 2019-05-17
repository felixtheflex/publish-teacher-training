FactoryBot.define do
  factory :provider do
    sequence(:id)
    sequence(:provider_code) { |n| "A#{n}" }
    provider_name { "ACME SCITT #{provider_code}" }
    accredited_body? { false }
  end
end
