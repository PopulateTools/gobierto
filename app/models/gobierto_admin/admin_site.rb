# frozen_string_literal: true

require_dependency "gobierto_admin"

module GobiertoAdmin
  class AdminSite < ApplicationRecord
    belongs_to :admin
    belongs_to :site

    validates :admin_id, :site_id, presence: true
    validates :admin_id, uniqueness: { scope: :site_id }
  end
end
