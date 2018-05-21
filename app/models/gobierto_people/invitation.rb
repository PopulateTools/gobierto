# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Invitation < ApplicationRecord
    include GobiertoCommon::Metadatable

    belongs_to :person

    validates :person, :organizer, :title, :start_date, :end_date, presence: true

    metadata_attributes :organic_unit, :expenses_financed_by_organizer
  end
end
