FactoryBot.define do
  factory :user do
    name { "Test User" }
    vacation_start_date { nil }
    vacation_end_date { nil }

    # 一意なemailとslack_idを生成する
    sequence :email do |n|
      "user#{n}@example.com"
    end

    sequence :slack_id do |n|
      "U#{n.to_s.rjust(6, '0')}"
    end

    trait :on_vacation do
      vacation_start_date { Date.current - 1.day }
      vacation_end_date { Date.current + 1.day }
    end

    trait :past_vacation do
      vacation_start_date { Date.current - 3.days }
      vacation_end_date { Date.current - 1.day }
    end
  end
end
