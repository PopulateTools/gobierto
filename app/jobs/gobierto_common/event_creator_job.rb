# frozen_string_literal: true

class GobiertoCommon::EventCreatorJob < ActiveJob::Base
  mattr_accessor :bouncer
  queue_as :event_creators

  DELAY = 20

  self.bouncer ||= Sidekiq::EventBouncer.new(self, DELAY)

  def perform(user_id, site_id, properties)
    # - We only want to debounce this if it has been enqueued (perform_later).
    #   If it' been called with perform_now (and enqueued_at is nil), no need to check that.
    return if enqueued_at.present? && !self.class.bouncer.let_in?(user_id, site_id, properties)

    last_visit_id = Ahoy::Visit.where(user_id: user_id).order(id: :desc).limit(1).pluck(:id).first

    if last_visit_id
      create_event last_visit_id, user_id, site_id, properties
    else
      # If the (ahoy) visit does not exist yet, re-enqueue the job for the next few minutes.
      bouncer.debounce user_id, site_id, properties
    end
  end

  private

  def create_event(last_visit_id, user_id, site_id, properties)
    Ahoy::Event.create!(
      visit_id: last_visit_id,
      time: Time.now,
      user_id: user_id,
      name: "#{properties[:controller]}##{properties[:action]}",
      site_id: site_id,
      properties: properties
    )
  end
end
