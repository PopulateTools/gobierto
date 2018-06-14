# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Gift < ApplicationRecord

    include GobiertoCommon::Metadatable

    belongs_to :person
    belongs_to :department

    scope :sorted, -> { order(name: :asc) }

    validates :name, presence: true

    metadata_attributes :type, :event_name, :delivered_by, :category_name

  end
end
