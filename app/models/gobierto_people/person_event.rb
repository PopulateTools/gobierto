require_dependency "gobierto_people"

module GobiertoPeople
  class PersonEvent < ApplicationRecord
    belongs_to :person

    has_many :locations, class_name: "PersonEventLocation", dependent: :destroy

    scope :past,     -> { approved.where("starts_at < ?", Date.current) }
    scope :upcoming, -> { approved.where("starts_at > ?", Date.current) }
    scope :sorted,   -> { order(starts_at: :asc) }

    enum state: { pending: 0, approved: 1 }

    def past?
      starts_at < Date.current
    end

    def upcoming?
      starts_at > Date.current
    end
  end
end
