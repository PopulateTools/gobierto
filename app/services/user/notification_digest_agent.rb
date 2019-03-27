# frozen_string_literal: true

class User::NotificationDigestAgent
  class User::InvalidNotificationFrequency < StandardError; end

  attr_reader :frequency

  def initialize(frequency)
    @frequency = frequency.to_s
  end

  def call
    unless User.respond_to?("#{frequency}_notifications")
      raise(
        User::InvalidNotificationFrequency,
        "Valid notification frequencies are: #{User.notification_frequencies.keys}"
      )
    end

    build_notification_digests_for("#{frequency}_notifications")
  end

  private

  def build_notification_digests_for(notification_frequency_name)
    [].tap do |notification_digest_summary|
      User.select(:id).send(notification_frequency_name).find_each do |user|
        notification_digest_summary.push(
          User::NotificationDigest.new(user.id, frequency).call
        )
      end
    end
  end
end
