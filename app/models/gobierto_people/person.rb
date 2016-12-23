module GobiertoPeople
  class Person < ApplicationRecord
    belongs_to :admin, class_name: "GobiertoAdmin::Admin"
    belongs_to :site

    scope :sorted, -> { order(created_at: :desc) }

    enum visibility_level: { draft: 0, active: 1 }
  end
end
