# frozen_string_literal: true

module GobiertoAdmin
  class VersionedResourceDecorator < BaseDecorator
    def initialize(resource)
      @object = resource
    end

    def has_versions?
      @has_versions ||= respond_to?(:paper_trail)
    end

    def has_publication_status?
      @has_publication_status ||= respond_to?(:visibility_level)
    end

    def versions_count
      @versions_count ||= versions.length
    end

    def new_version?
      @new_version ||= new_record?
    end

    def current_version
      @current_version = last_version? ? versions_count : version.index
    end

    def published_version_number
      return nil unless has_publication_status? && published?

      @published_version_number ||= live_version.published_version
    end

    def last_version?
      @last_version ||= paper_trail.live?
    end

    def current_version_published?
      published_version_number == current_version
    end

    def current_version_publication_status
      current_version_published? ? :approved : :not_published
    end

    def published?
      return false if new_record?

      live_version.published?
    end

    def current_version_publication_step
      current_version_published? ? :published : :publicable
    end

    def live_version
      @live_version ||= new_record? || !has_versions? ? self : self.class.find(id)
    end

    def recent_versions(limit = 9)
      @recent_versions ||= versions.unscope(:order).order(created_at: :desc).limit(limit)
    end
  end
end
