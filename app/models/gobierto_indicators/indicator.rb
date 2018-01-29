# frozen_string_literal: true

require_dependency "gobierto_indicators"

module GobiertoIndicators
  class Indicator < ApplicationRecord
    belongs_to :site
  end
end
