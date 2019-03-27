# frozen_string_literal: true

class GobiertoCalendars::EventAttendeeSerializer < ActiveModel::Serializer
  attributes :id, :attendee_name, :attendee_position, :person_id

  def attendee_name
    object.name.presence || object.person.try(:name)
  end

    def attendee_position
    object.charge.presence || object.person.try(:charge)
  end
end
