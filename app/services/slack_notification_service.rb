require "net/http"
require "json"

class SlackNotificationService
  def initialize
    @webhook_url = Rails.application.credentials.dig(:slack, :webhook_url) || ENV["SLACK_WEBHOOK_URL"]
    @channel_id = Rails.application.credentials.dig(:slack, :channel_id) || ENV["SLACK_CHANNEL_ID"] || "C095GP97S90"
  end

  def send_assignment_notification(assignment)
    return unless @webhook_url.present?

    message = build_assignment_message(assignment)
    send_to_slack(message)
  end

  def send_assignment_update_notification(assignment, old_user_name)
    return unless @webhook_url.present?

    message = build_assignment_update_message(assignment, old_user_name)
    send_to_slack(message)
  end

  def send_weekly_assignment_notification(assignments)
    return unless @webhook_url.present?

    message = build_weekly_assignment_message(assignments)
    send_to_slack(message)
  end

  private

  def build_assignment_message(assignment)
    {
      text: "🎯 アイスブレイク当番のお知らせ",
      attachments: [
        {
          color: "good",
          fields: [
            {
              title: "当番者",
              value: assignment.user.name,
              short: true
            },
            {
              title: "日付",
              value: assignment.assignment_date.strftime("%Y年%m月%d日 (%a)"),
              short: true
            },
            {
              title: "Slack ID",
              value: "<@#{assignment.user.slack_id}>",
              short: true
            }
          ],
          footer: "アイスブレイ君",
          ts: Time.current.to_i
        }
      ]
    }
  end

  def build_assignment_update_message(assignment, old_user_name)
    {
      text: "🔄 アイスブレイク当番の変更のお知らせ",
      attachments: [
        {
          color: "warning",
          fields: [
            {
              title: "変更前",
              value: old_user_name,
              short: true
            },
            {
              title: "変更後",
              value: assignment.user.name,
              short: true
            },
            {
              title: "日付",
              value: assignment.assignment_date.strftime("%Y年%m月%d日 (%a)"),
              short: true
            },
            {
              title: "新しい担当者",
              value: "<@#{assignment.user.slack_id}>",
              short: true
            }
          ],
          footer: "アイスブレイ君",
          ts: Time.current.to_i
        }
      ]
    }
  end

  def build_weekly_assignment_message(assignments)
    fields = assignments.map do |assignment|
      {
        title: assignment.assignment_date.strftime("%m/%d (%a)"),
        value: "#{assignment.user.name} (<@#{assignment.user.slack_id}>)",
        short: true
      }
    end

    {
      text: "📅 今週のアイスブレイク当番表",
      attachments: [
        {
          color: "warning",
          fields: fields,
          footer: "アイスブレイ君",
          ts: Time.current.to_i
        }
      ]
    }
  end

  def send_to_slack(message)
    uri = URI(@webhook_url)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.path)
    request["Content-Type"] = "application/json"
    request.body = message.to_json

    response = http.request(request)

    Rails.logger.info "Slack notification sent: #{response.code} - #{response.message}"

    unless response.code == "200"
      Rails.logger.error "Failed to send Slack notification: #{response.body}"
    end
  rescue => e
    Rails.logger.error "Error sending Slack notification: #{e.message}"
  end
end
