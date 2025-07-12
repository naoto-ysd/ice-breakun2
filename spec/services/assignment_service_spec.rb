require 'rails_helper'

RSpec.describe AssignmentService, type: :service do
  describe '#assign_duty' do
    let(:assignment_date) { Date.current }
    let(:method) { 'custom' }
    let(:service) { AssignmentService.new(assignment_date, method) }

    context 'when users are available' do
      let!(:user1) { create(:user, name: 'User 1') }
      let!(:user2) { create(:user, name: 'User 2') }
      let(:slack_service) { instance_double(SlackNotificationService) }

      before do
        allow(SlackNotificationService).to receive(:new).and_return(slack_service)
        allow(slack_service).to receive(:send_assignment_notification)
      end

      it 'creates a new duty assignment' do
        expect { service.assign_duty }.to change(DutyAssignment, :count).by(1)
      end

      it 'sends Slack notification' do
        assignment = service.assign_duty
        expect(slack_service).to have_received(:send_assignment_notification).with(assignment)
      end

      it 'assigns the user with the least duty count' do
        # user1に既に1つの当番を割り当て（異なる日付で）
        create(:duty_assignment, user: user1, status: 'completed', assignment_date: Date.current - 1.day)

        assignment = service.assign_duty
        expect(assignment.user).to eq(user2)
      end

      it 'continues to create assignment even if Slack notification fails' do
        allow(slack_service).to receive(:send_assignment_notification).and_raise(StandardError.new('Slack error'))
        allow(Rails.logger).to receive(:error)

        expect { service.assign_duty }.to change(DutyAssignment, :count).by(1)
        expect(Rails.logger).to have_received(:error).with('Failed to send Slack notification: Slack error')
      end
    end

    context 'when assignment already exists for the date' do
      let!(:user) { create(:user) }
      let!(:existing_assignment) { create(:duty_assignment, user: user, assignment_date: assignment_date) }

      it 'raises an error' do
        expect { service.assign_duty }.to raise_error(/既に割り当てられています/)
      end
    end

    context 'when all users are on vacation' do
      let!(:user) { create(:user, :on_vacation) }

      it 'raises an error' do
        expect { service.assign_duty }.to raise_error(/当番に割り当て可能なユーザーがいません/)
      end
    end

    context 'when no users exist' do
      it 'raises an error' do
        expect { service.assign_duty }.to raise_error(/当番に割り当て可能なユーザーがいません/)
      end
    end
  end

  describe '.available_methods' do
    it 'returns available assignment methods' do
      expect(AssignmentService.available_methods).to eq([ 'custom' ])
    end
  end
end
