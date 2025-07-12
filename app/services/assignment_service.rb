class AssignmentService
  def initialize(assignment_date = Date.current)
    @assignment_date = assignment_date
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
      status: "pending"
    )

    # Slack通知を送信
    send_slack_notification(assignment)

    assignment
  end

  def assign_duty_to_user(user)
    if existing_assignment
      raise "#{@assignment_date}の当番は既に割り当てられています（#{existing_assignment.user.name}）"
    end

    # 選択されたユーザーが休暇中でないかチェック
    if user_on_vacation?(user)
      raise "#{user.name}は休暇中のため、当番に割り当てることができません"
    end

    assignment = DutyAssignment.create!(
      user: user,
      assignment_date: @assignment_date,
      status: "pending"
    )

    # Slack通知を送信
    send_slack_notification(assignment)

    assignment
  end

  def update_duty_assignment(user)
    assignment = existing_assignment

    unless assignment
      raise "#{@assignment_date}の当番が見つかりません"
    end

    # 選択されたユーザーが休暇中でないかチェック
    if user_on_vacation?(user)
      raise "#{user.name}は休暇中のため、当番に割り当てることができません"
    end

    old_user_name = assignment.user.name
    assignment.update!(user: user)

    # Slack通知を送信
    send_slack_update_notification(assignment, old_user_name)

    assignment
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
    # 最も当番回数の少ないユーザーを選択
    users.min_by(&:total_duty_count)
  end

  def user_on_vacation?(user)
    return false unless user.vacation_start_date && user.vacation_end_date

    user.vacation_start_date <= Date.current && user.vacation_end_date >= Date.current
  end

  def send_slack_notification(assignment)
    SlackNotificationService.new.send_assignment_notification(assignment)
  rescue => e
    Rails.logger.error "Failed to send Slack notification: #{e.message}"
    # エラーが発生してもassignmentの作成は成功させる
  end

  def send_slack_update_notification(assignment, old_user_name)
    SlackNotificationService.new.send_assignment_update_notification(assignment, old_user_name)
  rescue => e
    Rails.logger.error "Failed to send Slack update notification: #{e.message}"
    # エラーが発生してもassignmentの更新は成功させる
  end
end
