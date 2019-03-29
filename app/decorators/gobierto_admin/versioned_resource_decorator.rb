# frozen_string_literal: true

module GobiertoAdmin
  class VersionedResourceDecorator < BaseDecorator
    def initialize(resource)
      @object = resource
    end

    def has_versions?
      @has_versions ||= respond_to?(:paper_trail)
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

    def last_version?
      @last_version ||= paper_trail.live?
    end

    def live_version
      @live_version ||= new_record? || !has_versions? ? self : self.class.find(id)
    end

    def recent_versions(limit = 9)
      @recent_versions ||= versions.unscope(:order).order(created_at: :desc).limit(limit)
    end
  end
end
