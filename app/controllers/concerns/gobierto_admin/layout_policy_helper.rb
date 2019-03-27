# frozen_string_literal: true

module GobiertoAdmin
  module LayoutPolicyHelper
    extend ActiveSupport::Concern

    private

    def can_manage_sites?
      @manage_sites ||= LayoutPolicy.new(current_admin, :manage_sites).can?
    end
  end
end
