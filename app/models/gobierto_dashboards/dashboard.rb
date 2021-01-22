# frozen_string_literal: true

require_relative "../gobierto_dashboards"

module GobiertoDashboards
  class Dashboard < ApplicationRecord
    belongs_to :site

    scope :sorted, -> { order(data_updated_at: :desc) }
    scope :for_context, ->(resource) { where(context: resource.is_a?(String) ? GobiertoCommon::ContextService.new(resource).context : resource.to_global_id.to_s) }

    translates :title

    enum visibility_level: { draft: 0, active: 1 }

    validates :site, presence: true

    def custom_fields
      site.custom_fields.where(uid: custom_field_uids)
    end

    def custom_field_records
      if context_resource.present? && site.custom_fields.where(instance: context_resource).exists?
        site.custom_field_records.where(custom_fields: { uid: custom_fields_uids, instance: context_resource })
      else
        site.custom_field_records.where(item: context_resource, custom_fields: { uid: custom_fields_uids })
      end
    end

    def custom_fields_uids
      widgets_configuration.map { |widget| widget["indicator"] }.compact
    end

    def context_resource
      @context_resource ||= GobiertoCommon::ContextService.new(context).resource
    end
  end
end
