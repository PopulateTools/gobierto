# frozen_string_literal: true

module GobiertoAdmin
  module ApplicationHelper
    def current_admin_label
      return unless current_admin

      admin_label_for(current_admin)
    end

    def admin_label_for(admin)
      return admin.name if admin.regular?

      "#{admin.name} (#{admin.authorization_level})"
    end
  end
end
