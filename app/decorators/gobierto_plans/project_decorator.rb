# frozen_string_literal: true

module GobiertoPlans
  class ProjectDecorator < BaseDecorator
    attr_reader :plan, :site

    def initialize(project, opts = {})
      @object = project
      options = opts[:opts] || {}
      @plan = options[:plan]
      @site = options[:site]
    end

    def version_index
      @version_index ||= published_version - versions.count
    end

    def at_current_version
      @at_current_version ||= begin
                                versioned_project = version_index.negative? ? versions[version_index].reify : self

                                versioned_project.tap do |attributes|
                                  attributes.assign_attributes node_plugins_attributes
                                end
                              end
    end

    private

    def node_plugins_attributes
      {}
    end
  end
end
