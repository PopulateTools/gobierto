# frozen_string_literal: true

module GobiertoCalendars
  class EventAttendee < ApplicationRecord
    belongs_to :person, class_name: "GobiertoPeople::Person", optional: true
    belongs_to :event

    validates :person, presence: true, unless: :custom_person_present?
    validates :name, presence: true, unless: :person_present?

    scope :with_department, lambda {
      joins(:event).left_outer_joins(
        person: { historical_charges: :department }
      ).where(
        %{
          (#{GobiertoPeople::Charge.table_name}.department_id IS NOT NULL)
          AND
          (#{Event.table_name}.starts_at >= #{GobiertoPeople::Charge.table_name}.start_date OR #{GobiertoPeople::Charge.table_name}.start_date IS NULL)
          AND
          (#{Event.table_name}.starts_at <= #{GobiertoPeople::Charge.table_name}.end_date OR #{GobiertoPeople::Charge.table_name}.end_date IS NULL)
        }
      )
    }

    private

    def person_present?
      person.present?
    end

    def custom_person_present?
      name.present? || charge.present?
    end
  end
end
