# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Charge < ApplicationRecord

    belongs_to :person
    belongs_to :department

    translates :name

    def to_s
      name
    end
  end
end
