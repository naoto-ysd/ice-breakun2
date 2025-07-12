require_relative "../services/assignment_service"

class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [ :show, :edit, :update, :destroy ]

  # AssignmentServiceを明示的に参照して自動読み込みを確実にする
  def self.load_assignment_service
    AssignmentService
  end

  def index
    @assignments = DutyAssignment.includes(:user).recent.limit(20)
    @current_assignment = DutyAssignment.for_date(Date.current).first
    @upcoming_assignments = DutyAssignment.where(assignment_date: Date.current..1.week.from_now).recent
  end

  def show
  end

  def new
    @assignment = DutyAssignment.new
    @available_methods = AssignmentService.available_methods
  end

  def create
    begin
      assignment_service = AssignmentService.new(
        assignment_params[:assignment_date].present? ? Date.parse(assignment_params[:assignment_date]) : Date.current,
        assignment_params[:assignment_method] || :custom
      )

      @assignment = assignment_service.assign_duty

      redirect_to assignment_path(@assignment), notice: "当番が正常に割り当てられました"
    rescue => e
      @available_methods = AssignmentService.available_methods
      @assignment = DutyAssignment.new(assignment_params)
      flash.now[:alert] = e.message
      render :new
    end
  end

  def edit
  end

  def update
    if @assignment.update(assignment_params)
      redirect_to assignment_path(@assignment), notice: "当番が正常に更新されました"
    else
      render :edit
    end
  end

  def complete
    @assignment = DutyAssignment.find(params[:id])
    @assignment.mark_as_completed!
    redirect_to assignments_path, notice: "当番が完了しました"
  end

  def cancel
    @assignment = DutyAssignment.find(params[:id])
    @assignment.mark_as_cancelled!
    redirect_to assignments_path, notice: "当番がキャンセルされました"
  end

  def destroy
    @assignment.destroy
    redirect_to assignments_path, notice: "当番が削除されました"
  end

  def assign_today
    begin
      Rails.logger.info "=== assign_today called with method: #{params[:method]}"
      assignment_service = AssignmentService.new(Date.current, params[:method] || :custom)
      Rails.logger.info "=== AssignmentService created"
      assignment = assignment_service.assign_duty
      Rails.logger.info "=== Assignment created: #{assignment.inspect}"

      redirect_to assignment_path(assignment), notice: "今日の当番が割り当てられました（#{assignment.user.name}さん）"
    rescue => e
      Rails.logger.error "=== Assignment failed: #{e.class} - #{e.message}"
      Rails.logger.error "=== Backtrace: #{e.backtrace.first(5)}"
      redirect_to assignments_path, alert: e.message
    end
  end

  def assign_week
    begin
      assignments = []
      method = params[:method] || :custom

      (Date.current..6.days.from_now).each do |date|
        # 土日をスキップする場合
        next if date.saturday? || date.sunday?

        assignment_service = AssignmentService.new(date, method)
        assignments << assignment_service.assign_duty
      end

      # 今週の当番表をSlackに通知
      if assignments.any?
        send_weekly_slack_notification(assignments)
      end

      redirect_to assignments_path, notice: "今週の当番が割り当てられました（#{assignments.size}件）"
    rescue => e
      redirect_to assignments_path, alert: e.message
    end
  end

  private

  def set_assignment
    @assignment = DutyAssignment.find(params[:id])
  end

  def assignment_params
    params.require(:duty_assignment).permit(:assignment_date, :assignment_method, :user_id)
  end

  def send_weekly_slack_notification(assignments)
    SlackNotificationService.new.send_weekly_assignment_notification(assignments)
  rescue => e
    Rails.logger.error "Failed to send weekly Slack notification: #{e.message}"
    # エラーが発生してもassignmentの作成は成功させる
  end
end
