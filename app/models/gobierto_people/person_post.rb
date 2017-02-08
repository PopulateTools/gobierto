require_dependency "gobierto_people"

module GobiertoPeople
  class PersonPost < ApplicationRecord
    include User::Subscribable

    belongs_to :person, counter_cache: :posts_count

    scope :sorted, -> { order(created_at: :desc) }
    scope :by_tag, ->(*tags) { where("tags @> ARRAY[?]::varchar[]", tags) }

    delegate :site_id, to: :person
    delegate :admin_id, to: :person

    enum visibility_level: { draft: 0, active: 1 }

    def visible?
      active?
    end

    def parameterize
      { person_id: person, id: self }
    end
  end
end
