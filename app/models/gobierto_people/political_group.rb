require_dependency "gobierto_people"

module GobiertoPeople
  class PoliticalGroup < ApplicationRecord
    belongs_to :admin, class_name: "GobiertoAdmin::Admin"
    belongs_to :site

    has_many :people
  end
end
