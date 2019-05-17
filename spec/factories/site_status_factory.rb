FactoryBot.define do
  factory :site_status do
    sequence(:id)
    status { 'running' }

    trait :full_time_and_part_time do
      vac_status { 'both_full_time_and_part_time_vacancies' }
    end

    trait :full_time do
      vac_status { 'full_time_vacancies' }
    end

    trait :part_time do
      vac_status { 'part_time_vacancies' }
    end

    trait :no_vacancies do
      vac_status { 'no_vacancies' }
    end
  end
end
