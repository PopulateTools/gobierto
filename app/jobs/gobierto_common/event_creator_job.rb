# frozen_string_literal: true

class GobiertoCommon::EventCreatorJob < ActiveJob::Base
  queue_as :event_creators

  def perform(user_id, properties)
    create_event user_id, properties
  end

  private

  def last_visit_id(user_id)
    return if user_id.blank?

    Ahoy::Visit.where(user_id: user_id).order(id: :desc).limit(1).pluck(:id).first
  end

  def site_id(user_id)
    return if user_id.blank?

    User.find_by(id: user_id)&.site_id
  end

  def create_event(user_id, properties)
    Ahoy::Event.create!(
      visit_id: last_visit_id(user_id),
      time: Time.now,
      user_id: user_id,
      name: "#{properties[:controller]}##{properties[:action]}",
      site_id: site_id(user_id),
      properties: properties
    )
  end
end
