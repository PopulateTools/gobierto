# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Department < ApplicationRecord

    belongs_to :site

    scope :sorted, -> { order(name: :asc) }

    validates :name, presence: true

  end
end
