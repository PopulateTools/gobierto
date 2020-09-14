# frozen_string_literal: true

module GobiertoIndicators
  class Indicator < ApplicationRecord
    belongs_to :site
  end
end
