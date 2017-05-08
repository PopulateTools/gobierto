require_dependency "gobierto_people"

module GobiertoPeople
  class PersonEventAttendee < ApplicationRecord
    belongs_to :person
    belongs_to :person_event

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
