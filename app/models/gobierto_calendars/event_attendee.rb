# frozen_string_literal: true

module GobiertoCalendars
  class EventAttendee < ApplicationRecord
    belongs_to :person, class_name: "GobiertoPeople::Person", optional: true
    belongs_to :event

    validates :person, presence: true, unless: :custom_person_present?
    validates :name, presence: true, unless: :person_present?

    private

    def person_present?
      person.present?
    end

    def custom_person_present?
      name.present? || charge.present?
    end
  end
end
