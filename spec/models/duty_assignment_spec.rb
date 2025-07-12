require 'rails_helper'

RSpec.describe DutyAssignment, type: :model do
  describe 'associations' do
    it { should belong_to(:user) }
  end

  describe 'validations' do
    it { should validate_presence_of(:assignment_date) }
    it { should validate_presence_of(:status) }
    it { should validate_inclusion_of(:status).in_array(%w[pending completed cancelled]) }
  end

  describe 'scopes' do
    let(:user) { create(:user) }
    let!(:pending_assignment) { create(:duty_assignment, user: user, status: 'pending') }
    let!(:completed_assignment) { create(:duty_assignment, user: user, status: 'completed') }
    let!(:cancelled_assignment) { create(:duty_assignment, user: user, status: 'cancelled') }

    describe '.pending' do
      it 'returns only pending assignments' do
        expect(DutyAssignment.pending).to include(pending_assignment)
        expect(DutyAssignment.pending).not_to include(completed_assignment)
      end
    end

    describe '.completed' do
      it 'returns only completed assignments' do
        expect(DutyAssignment.completed).to include(completed_assignment)
        expect(DutyAssignment.completed).not_to include(pending_assignment)
      end
    end

    describe '.for_date' do
      let(:date) { Date.current }
      let!(:assignment_for_date) { create(:duty_assignment, user: user, assignment_date: date) }

      it 'returns assignments for the specified date' do
        expect(DutyAssignment.for_date(date)).to include(assignment_for_date)
      end
    end

    describe '.recent' do
      it 'returns assignments in descending order by assignment_date' do
        user = create(:user)
        old_assignment = create(:duty_assignment, user: user, assignment_date: Date.parse('2025-01-01'))
        recent_assignment = create(:duty_assignment, user: user, assignment_date: Date.parse('2025-01-02'))

        assignments = DutyAssignment.where(user: user).recent
        expect(assignments.first).to eq(recent_assignment)
        expect(assignments.last).to eq(old_assignment)
      end
    end
  end

  describe '#mark_as_completed!' do
    let(:assignment) { create(:duty_assignment, status: 'pending') }

    it 'updates status to completed' do
      assignment.mark_as_completed!
      expect(assignment.status).to eq('completed')
    end

    it 'sets completed_at timestamp' do
      assignment.mark_as_completed!
      expect(assignment.completed_at).to be_present
    end
  end

  describe '#mark_as_cancelled!' do
    let(:assignment) { create(:duty_assignment, status: 'pending') }

    it 'updates status to cancelled' do
      assignment.mark_as_cancelled!
      expect(assignment.status).to eq('cancelled')
    end
  end

  describe '#pending?' do
    it 'returns true for pending assignments' do
      assignment = create(:duty_assignment, status: 'pending')
      expect(assignment.pending?).to be true
    end

    it 'returns false for non-pending assignments' do
      assignment = create(:duty_assignment, status: 'completed')
      expect(assignment.pending?).to be false
    end
  end

  describe '#completed?' do
    it 'returns true for completed assignments' do
      assignment = create(:duty_assignment, status: 'completed')
      expect(assignment.completed?).to be true
    end

    it 'returns false for non-completed assignments' do
      assignment = create(:duty_assignment, status: 'pending')
      expect(assignment.completed?).to be false
    end
  end

  describe '#cancelled?' do
    it 'returns true for cancelled assignments' do
      assignment = create(:duty_assignment, status: 'cancelled')
      expect(assignment.cancelled?).to be true
    end

    it 'returns false for non-cancelled assignments' do
      assignment = create(:duty_assignment, status: 'pending')
      expect(assignment.cancelled?).to be false
    end
  end

  describe '#overdue?' do
    context 'when assignment is pending and date is in the past' do
      let(:assignment) { create(:duty_assignment, status: 'pending', assignment_date: Date.current - 1.day) }

      it 'returns true' do
        expect(assignment.overdue?).to be true
      end
    end

    context 'when assignment is completed' do
      let(:assignment) { create(:duty_assignment, status: 'completed', assignment_date: Date.current - 1.day) }

      it 'returns false' do
        expect(assignment.overdue?).to be false
      end
    end

    context 'when assignment is pending but date is in the future' do
      let(:assignment) { create(:duty_assignment, status: 'pending', assignment_date: Date.current + 1.day) }

      it 'returns false' do
        expect(assignment.overdue?).to be false
      end
    end
  end
end
