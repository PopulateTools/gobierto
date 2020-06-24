# frozen_string_literal: true

module GobiertoPlans
  class BaseSerializer < ActiveModel::Serializer
    def current_site
      Site.find((instance_options[:plan].presence || object).site.id)
    end

    def exclude_links?
      instance_options[:exclude_links]
    end

    def exclude_relationships?
      instance_options[:exclude_relationships]
    end

    def with_translations?
      instance_options[:with_translations]
    end

    def include_draft?
      instance_options[:include_draft]
    end
  end
end
