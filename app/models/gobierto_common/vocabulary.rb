# frozen_string_literal: true

module GobiertoCommon
  class Vocabulary < ApplicationRecord
    belongs_to :site
    validates :site, :name, presence: true
    validates :name, uniqueness: { scope: :site }
  end
end
