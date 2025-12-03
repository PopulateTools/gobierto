# frozen_string_literal: true

module GobiertoPlans
  class ProjectDecorator < BaseDecorator

    def initialize(project, opts = {})
      @object = project
      options = opts[:opts] || {}
      @plan = options[:plan]
      @site = options[:site]
      @admin = options[:admin]
    end

    def plan
      @plan ||= GobiertoPlans::Plan.find_by(categories_vocabulary: project.categories.first.vocabulary)
    end

    def site
      @site ||= plan&.site
    end

    def project
      self
    end

    def site_id
      site&.id
    end

    def admin_id
      @admin&.id
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

    def uid
      @uid ||= "#{CategoryTermDecorator.new(category).uid}.#{@plan.nodes.with_category(category&.id).published.index(object)}"
    end

    def category
      categories.find_by(vocabulary: @plan.categories_vocabulary)
    end

    private

    def node_plugins_attributes
      {}
    end

  end
end
