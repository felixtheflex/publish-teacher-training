FactoryBot.define do
  factory :user, class: Hash do
    sequence(:id)
    first_name { Faker::Name.first_name }
    last_name  { Faker::Name.last_name }
    email      { Faker::Internet.safe_email("#{first_name} #{last_name}") }
    state      { 'transitioned' }
    accept_terms_date_utc { Time.current }
    opted_in?  { false }

    trait :new do
      state { 'new' }
    end

    trait :opted_in do
      opted_in? { true }
    end

    initialize_with do |_evaluator|
      data_attributes = attributes.except(:id)

      JSONAPIMockSerializable.new(
        id,
        'users',
        attributes: data_attributes
      )
    end
  end
end
