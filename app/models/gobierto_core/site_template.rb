# frozen_string_literal: true

require_dependency "gobierto_core"

module GobiertoCore
  class SiteTemplate < ApplicationRecord
    belongs_to :template
    belongs_to :site
  end
end
