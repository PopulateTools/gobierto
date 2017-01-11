require_dependency "gobierto_people"

module GobiertoPeople
  class PersonEventLocation < ApplicationRecord
    belongs_to :person_event

    validates :name, :address, presence: true
  end
end
