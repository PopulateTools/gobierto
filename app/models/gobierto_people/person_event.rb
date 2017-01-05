require_dependency "gobierto_people"

module GobiertoPeople
  class PersonEvent < ApplicationRecord
    belongs_to :person

    has_many :locations, class_name: "PersonEventLocation", dependent: :destroy
    has_many :attendees, class_name: "PersonEventAttendee", dependent: :destroy

    scope :past,     -> { approved.where("starts_at <= ?", Time.zone.now) }
    scope :upcoming, -> { approved.where("starts_at > ?", Time.zone.now) }
    scope :sorted,   -> { order(starts_at: :asc) }

    enum state: { pending: 0, approved: 1 }

    def past?
      starts_at <= Time.zone.now
    end

    def upcoming?
      starts_at > Time.zone.now
    end
  end
end
