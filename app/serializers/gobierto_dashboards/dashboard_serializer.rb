# frozen_string_literal: true

module GobiertoDashboards
  class DashboardSerializer < BaseSerializer
    include Rails.application.routes.url_helpers

    attribute :title, unless: :with_translations?
    attribute :title_translations, if: :with_translations?
    attributes :visibility_level, :context, :widgets_configuration
  end
end
