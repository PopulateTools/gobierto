require_dependency "gobierto_people"

module GobiertoPeople
  class PersonStatement < ApplicationRecord
    include ::GobiertoCommon::DynamicContent

    belongs_to :person, counter_cache: :statements_count

    scope :sorted, -> { order(published_on: :desc, created_at: :desc) }

    enum visibility_level: { draft: 0, active: 1 }
  end
end
