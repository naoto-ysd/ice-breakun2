class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [ :show, :edit, :update, :destroy ]

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

      redirect_to @assignment, notice: "当番が正常に割り当てられました"
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
      redirect_to @assignment, notice: "当番が正常に更新されました"
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
      assignment_service = AssignmentService.new(Date.current, params[:method] || :custom)
      assignment = assignment_service.assign_duty

      redirect_to assignment, notice: "今日の当番が割り当てられました"
    rescue => e
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
end
