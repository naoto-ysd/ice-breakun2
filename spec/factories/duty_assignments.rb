FactoryBot.define do
  factory :duty_assignment do
    association :user
    assignment_date { Date.current }
    status { "pending" }
    completed_at { nil }

    trait :pending do
      status { "pending" }
      completed_at { nil }
    end

    trait :completed do
      status { "completed" }
      completed_at { Time.current }
    end

    trait :cancelled do
      status { "cancelled" }
      completed_at { nil }
    end

    trait :overdue do
      status { "pending" }
      assignment_date { Date.current - 1.day }
    end

    trait :future do
      assignment_date { Date.current + 1.day }
    end
  end
end
