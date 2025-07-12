class AssignmentService
  def initialize(assignment_date = Date.current, method = :random)
    @assignment_date = assignment_date
    @method = method.to_s
  end

  def assign_duty
    return existing_assignment if existing_assignment

    available_users = User.where.not(id: excluded_user_ids)

    if available_users.empty?
      raise "当番に割り当て可能なユーザーがいません"
    end

    selected_user = select_user(available_users)

    DutyAssignment.create!(
      user: selected_user,
      assignment_date: @assignment_date,
      assignment_method: @method,
      status: "pending"
    )
  end

  def self.available_methods
    %w[random custom]
  end

  private

  def existing_assignment
    @existing_assignment ||= DutyAssignment.for_date(@assignment_date).first
  end

  def excluded_user_ids
    # 休暇中のユーザーを除外
    User.select(:id).reject(&:available_for_duty?).map(&:id)
  end

  def select_user(users)
    case @method
    when "random"
      select_random_user(users)
    when "custom"
      select_custom_user(users)
    else
      raise "無効な割り当て方法: #{@method}"
    end
  end

  def select_random_user(users)
    users.sample
  end

  def select_custom_user(users)
    # カスタム選択のロジック（最も当番回数の少ないユーザー）
    users.min_by(&:total_duty_count)
  end
end
