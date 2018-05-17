# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class InterestGroup < ApplicationRecord

    include GobiertoCommon::Metadatable

    belongs_to :site

    scope :sorted, -> { order(name: :asc) }

    validates :name, presence: true

    metadata_attributes :status

  end
end
