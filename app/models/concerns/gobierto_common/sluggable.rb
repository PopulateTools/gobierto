# frozen_string_literal: true

module GobiertoCommon
  module Sluggable
    extend ActiveSupport::Concern

    included do
      before_validation :set_slug
      after_destroy :add_archived_to_slug
    end

    private

    def set_slug
      if slug.present? && !slug.include?("archived-")
        self.slug = self.slug.tr("_", " ").parameterize
        return
      end

      base_slug = attributes_for_slug.join("-").tr("_", " ").parameterize
      new_slug = base_slug

      count = 2

      if try(:site_id).present?
        while self.class.exists?(site: site, slug: new_slug)
          new_slug = "#{base_slug}-#{count}"
          count += 1
        end
      elsif try(:process_id).present?
        while self.class.exists?(process: process, slug: new_slug)
          new_slug = "#{base_slug}-#{count}"
          count += 1
        end
      end

      self.slug = new_slug
    end

    def add_archived_to_slug
      unless destroyed?
        update_attribute(:slug, "archived-" + id.to_s)
      end
    end
  end
end
