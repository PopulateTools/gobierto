# frozen_string_literal: true

module GobiertoAdmin
  class LayoutPolicy
    attr_reader :admin, :action

    def initialize(admin, action)
      @admin = admin
      @action = action
    end

    def can?
      case action
      when :manage_sites then manage?
      else false
      end
    end

    private

    def manage?
      admin.managing_user?
    end
  end
end
