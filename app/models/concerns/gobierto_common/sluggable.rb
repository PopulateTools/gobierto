# frozen_string_literal: true

module GobiertoCommon
  module Sluggable
    extend ActiveSupport::Concern

    included do
      before_validation :set_slug
    end

    private

    def set_slug
      return if self.slug.present? && !self.class.exists?(site: site, slug: self.slug)

      base_slug = if self.slug.present?
                    self.slug
                  else
                    attributes_for_slug.join('-').gsub('_', ' ').parameterize
                  end

      new_slug  = base_slug

      count = 2
      while self.class.exists?(site: site, slug: new_slug)
        new_slug = "#{base_slug}-#{count}"
        count += 1
      end

      self.slug = new_slug
    end
  end
end
