# frozen_string_literal: true

class GobiertoCommon::EventCreatorJob < ActiveJob::Base
  queue_as :event_creators

  def perform(site_id, user_id, visit_id, properties)
    create_event site_id, user_id, visit_id, properties
    update_visit_user(visit_id, user_id)
  end

  private

  def create_event(site_id, user_id, visit_id, properties)
    Ahoy::Event.create!(
      visit_id: visit_id,
      time: Time.now,
      user_id: user_id,
      name: "#{properties[:controller]}##{properties[:action]}",
      site_id: site_id,
      properties: properties
    )
  end

  def update_visit_user(visit_id, user_id)
    return if [visit_id, user_id].any?(&:blank?)

    visit = Ahoy::Visit.find_by(id: visit_id)

    return if visit.blank? || visit.user_id == user_id

    visit.update_attribute(:user_id, user_id)
  end
end
