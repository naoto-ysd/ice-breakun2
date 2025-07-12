require 'rails_helper'

RSpec.describe SlackNotificationService, type: :service do
  let(:user) { create(:user) }
  let(:assignment) { create(:duty_assignment, user: user) }
  let(:service) { described_class.new }

  before do
    allow(Rails.application.credentials).to receive(:dig).with(:slack, :webhook_url).and_return('https://hooks.slack.com/test')
    allow(Rails.application.credentials).to receive(:dig).with(:slack, :channel_id).and_return('C095GP97S90')
  end

  describe '#send_assignment_notification' do
    context 'when webhook_url is present' do
      it 'sends notification to Slack' do
        stub_request(:post, 'https://hooks.slack.com/test')
          .with(
            body: hash_including(
              'text' => '🎯 アイスブレイク当番のお知らせ'
            )
          )
          .to_return(status: 200, body: 'ok')

        expect { service.send_assignment_notification(assignment) }.not_to raise_error
      end
    end

    context 'when webhook_url is not present' do
      before do
        allow(Rails.application.credentials).to receive(:dig).with(:slack, :webhook_url).and_return(nil)
        allow(ENV).to receive(:[]).with('SLACK_WEBHOOK_URL').and_return(nil)
      end

      it 'does not send notification' do
        expect(service.send_assignment_notification(assignment)).to be_nil
      end
    end
  end

  describe '#send_weekly_assignment_notification' do
    let(:assignments) { create_list(:duty_assignment, 3, user: user) }

    context 'when webhook_url is present' do
      it 'sends weekly notification to Slack' do
        stub_request(:post, 'https://hooks.slack.com/test')
          .with(
            body: hash_including(
              'text' => '📅 今週のアイスブレイク当番表'
            )
          )
          .to_return(status: 200, body: 'ok')

        expect { service.send_weekly_assignment_notification(assignments) }.not_to raise_error
      end
    end
  end
end
