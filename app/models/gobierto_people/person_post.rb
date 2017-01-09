require_dependency "gobierto_people"

module GobiertoPeople
  class PersonPost < ApplicationRecord
    belongs_to :person

    scope :sorted, -> { order(created_at: :desc) }
    scope :by_tag, ->(*tags) { where("tags @> ARRAY[?]::varchar[]", tags) }

    enum visibility_level: { draft: 0, active: 1 }
  end
end
