require_dependency "gobierto_people"

module GobiertoPeople
  class PersonStatement < ApplicationRecord
    include ::GobiertoCommon::DynamicContent
    include User::Subscribable

    belongs_to :person, counter_cache: :statements_count

    scope :sorted, -> { order(published_on: :desc, created_at: :desc) }

    enum visibility_level: { draft: 0, active: 1 }

    delegate :site_id, to: :person
    delegate :admin_id, to: :person

    def visible?
      active?
    end

    def parameterize
      { person_id: person, id: self }
    end
  end
end
