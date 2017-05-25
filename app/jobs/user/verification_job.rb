# frozen_string_literal: true

class User::VerificationJob < ActiveJob::Base
  queue_as :user_verifications

  rescue_from(ActiveRecord::RecordNotFound) do
    retry_job queue: :user_verifications
  end

  def perform(user_verification)
    user_verification.verify!
  end
end
