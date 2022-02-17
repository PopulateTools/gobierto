# frozen_string_literal: true

class GobiertoCommon::EventCreatorJob < ActiveJob::Base
  queue_as :event_creators

  def perform(site_id, user_id, visit_id, properties)
    create_event site_id, user_id, visit_id, properties
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
end
