# frozen_string_literal: true

module GobiertoCommon
  module HasPermissionsGroup
    extend ActiveSupport::Concern

    included do
      has_one :admin_group, class_name: "GobiertoAdmin::AdminGroup", as: :resource
    end

  end
end
