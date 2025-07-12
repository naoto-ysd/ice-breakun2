require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'associations' do
    it { should have_many(:duty_assignments).dependent(:destroy) }
  end

  describe 'validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:email) }
    it { should validate_presence_of(:slack_id) }
    it { should validate_uniqueness_of(:email) }
    it { should validate_uniqueness_of(:slack_id) }
    it { should allow_value('test@example.com').for(:email) }
    it { should_not allow_value('invalid-email').for(:email) }
  end

  describe '#on_vacation?' do
    let(:user) { User.new(name: 'Test User', email: 'test@example.com', slack_id: 'U123') }

    context 'when vacation dates are not set' do
      it 'returns false' do
        expect(user.on_vacation?).to be false
      end
    end

    context 'when vacation dates are set' do
      before do
        user.vacation_start_date = Date.current - 1.day
        user.vacation_end_date = Date.current + 1.day
      end

      it 'returns true when current date is between vacation dates' do
        expect(user.on_vacation?).to be true
      end
    end

    context 'when vacation dates are in the past' do
      before do
        user.vacation_start_date = Date.current - 3.days
        user.vacation_end_date = Date.current - 1.day
      end

      it 'returns false' do
        expect(user.on_vacation?).to be false
      end
    end
  end

  describe '#available_for_duty?' do
    let(:user) { User.new(name: 'Test User', email: 'test@example.com', slack_id: 'U123') }

    context 'when not on vacation' do
      it 'returns true' do
        expect(user.available_for_duty?).to be true
      end
    end

    context 'when on vacation' do
      before do
        user.vacation_start_date = Date.current - 1.day
        user.vacation_end_date = Date.current + 1.day
      end

      it 'returns false' do
        expect(user.available_for_duty?).to be false
      end
    end
  end

  describe '#full_name' do
    let(:user) { User.new(name: 'Test User', email: 'test@example.com', slack_id: 'U123') }

    it 'returns the name' do
      expect(user.full_name).to eq('Test User')
    end
  end

    describe '#last_duty_assignment' do
    it 'returns the most recent duty assignment' do
      user = create(:user)
      old_assignment = create(:duty_assignment, user: user, assignment_date: Date.current - 1.day)
      recent_assignment = create(:duty_assignment, user: user, assignment_date: Date.current)

      expect(user.last_duty_assignment).to eq(recent_assignment)
    end
  end

  describe '#total_duty_count' do
    it 'returns the count of completed duty assignments' do
      user = create(:user)
      create(:duty_assignment, user: user, status: 'completed')
      create(:duty_assignment, user: user, status: 'pending')
      create(:duty_assignment, user: user, status: 'completed')

      expect(user.total_duty_count).to eq(2)
    end
  end
end
