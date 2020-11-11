# frozen_string_literal: true

module GobiertoCommon
  module Versionable
    extend ActiveSupport::Concern

    def object
      return @object if @live_object.present?

      @live_object = super
      @object = version_index&.negative? ? @live_object.versions[version_index].reify : @live_object
    end

    def version_index
      @version_index ||= if preloaded_versions_indexes?
                           instance_options.dig(:versions_indexes, object.id)
                         elsif @live_object.published_version.present?
                           @live_object.published_version - @live_object.versions.count
                         end
    end

    def preloaded_versions_indexes?
      @preloaded_versions_indexes ||= instance_options.has_key?(:versions_indexes)
    end
  end
end
