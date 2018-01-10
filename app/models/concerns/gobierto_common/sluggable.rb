# frozen_string_literal: true

module GobiertoCommon
  module Sluggable
    extend ActiveSupport::Concern

    included do
      before_create :set_slug
    end

    private

    def set_slug
      if slug.present?
        self.slug = self.slug.tr("_", " ").parameterize
        return
      end

      base_slug = attributes_for_slug.join("-").tr("_", " ").parameterize
      new_slug = base_slug

      count = 2
      if self.class.validators_on(:slug).first.options[:scope].first == :site
        while self.class.exists?(site: site, slug: new_slug)
          new_slug = "#{base_slug}-#{count}"
          count += 1
        end
      elsif self.class.validators_on(:slug).first.options[:scope].first == :process_id
        while self.class.exists?(process: process, slug: new_slug)
          new_slug = "#{base_slug}-#{count}"
          count += 1
        end
      end

      self.slug = new_slug
    end
  end
end
