FactoryBot.define do
  factory :recruitment_cycle do
    sequence(:id)
    year { '2019' }
    application_start_date { '2018-10-09' }

    trait :next_cycle do
      year { '2020' }
    end
  end
end
