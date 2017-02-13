require_dependency "gobierto_people"

module GobiertoPeople
  class PoliticalGroup < ApplicationRecord
    belongs_to :admin, class_name: "GobiertoAdmin::Admin"
    belongs_to :site

    has_many :people
    has_many :events, through: :people

    default_scope { order(id: :asc) }
  end
end
