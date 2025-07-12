class AssignmentService
  def initialize(assignment_date = Date.current, method = :custom)
    @assignment_date = assignment_date
    @method = method.to_s
  end

  def assign_duty
    if existing_assignment
      raise "#{@assignment_date}の当番は既に割り当てられています（#{existing_assignment.user.name}）"
    end

    available_users = User.where.not(id: excluded_user_ids)

    if available_users.empty?
      raise "当番に割り当て可能なユーザーがいません"
    end

    selected_user = select_user(available_users)

    assignment = DutyAssignment.create!(
      user: selected_user,
      assignment_date: @assignment_date,
      assignment_method: @method,
      status: "pending"
    )

    # Slack通知を送信
    send_slack_notification(assignment)

    assignment
  end

  def self.available_methods
    %w[custom]
  end

  private

  def existing_assignment
    @existing_assignment ||= DutyAssignment.for_date(@assignment_date).first
  end

  def excluded_user_ids
    # 休暇中のユーザーを除外
    User.where(
      "vacation_start_date <= ? AND vacation_end_date >= ?",
      Date.current,
      Date.current
    ).pluck(:id)
  end

  def select_user(users)
    case @method
    when "custom"
      select_custom_user(users)
    else
      raise "無効な割り当て方法: #{@method}"
    end
  end

  def select_custom_user(users)
    # カスタム選択のロジック（最も当番回数の少ないユーザー）
    users.min_by(&:total_duty_count)
  end

  def send_slack_notification(assignment)
    SlackNotificationService.new.send_assignment_notification(assignment)
  rescue => e
    Rails.logger.error "Failed to send Slack notification: #{e.message}"
    # エラーが発生してもassignmentの作成は成功させる
  end
end
