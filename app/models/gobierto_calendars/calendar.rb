require_dependency "gobierto_calendars"

module GobiertoCalendars
  class Calendar < ApplicationRecord
    belongs_to :owner, polymorphic: true
    has_many :events, dependent: :destroy

    validates :name, presence: true
  end
end
