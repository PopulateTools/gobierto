# frozen_string_literal: true

module GobiertoPlans
  class ProjectDecorator < BaseDecorator
    def initialize(project)
      @object = project
    end

    def version_index
      @version_index ||= published_version - versions.count
    end

    def at_current_version
      return self unless version_index.negative?

      versions[version_index].reify
    end
  end
end
