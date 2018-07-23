# frozen_string_literal: true

module GobiertoCommon
  class Vocabulary < ApplicationRecord
    belongs_to :site
    has_many :terms, dependent: :destroy

    validates :site, :name, presence: true
    validates :name, uniqueness: { scope: :site }
  end
end
