require_relative "../services/assignment_service"

class AssignmentsController < ApplicationController
  before_action :set_assignment, only: [ :show, :edit, :update, :destroy ]

  # AssignmentServiceを明示的に参照して自動読み込みを確実にする
  def self.load_assignment_service
    AssignmentService
  end

  def index
    @current_assignment = DutyAssignment.for_date(Date.current).first
  end

  def show
  end

  def new
    @assignment = DutyAssignment.new
  end

  def create
    begin
      assignment_service = AssignmentService.new(
        assignment_params[:assignment_date].present? ? Date.parse(assignment_params[:assignment_date]) : Date.current
      )

      @assignment = assignment_service.assign_duty

      redirect_to assignment_path(@assignment), notice: "当番が正常に割り当てられました"
    rescue => e
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
      Rails.logger.info "=== assign_today called"
      assignment_service = AssignmentService.new(Date.current)
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



  private

  def set_assignment
    @assignment = DutyAssignment.find(params[:id])
  end

  def assignment_params
    params.require(:duty_assignment).permit(:assignment_date, :user_id)
  end
end
