# frozen_string_literal: true

module GobiertoCore
  class SiteTemplate < ApplicationRecord
    belongs_to :template
    belongs_to :site
  end
end
