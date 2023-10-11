# frozen_string_literal: true

module GobiertoPlans
  module VersionsHelpers
    extend ActiveSupport::Concern

    def set_publication(node)
      return unless plan.publish_last_version_automatically?

      node.published_version = node.versions.count
      node.published!
    end
  end
end
