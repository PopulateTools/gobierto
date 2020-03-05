# frozen_string_literal: true

module GobiertoCommon
  module HasExternalId
    extend ActiveSupport::Concern

    included do
      before_validation :set_external_id
    end

    def set_external_id
      return if external_id.present?

      self.external_id = new_external_id
    end

    def new_external_id
      base_id = id || self.class.maximum(:id) + 1
      if (related_external_ids = self.class.where("external_id ~* ?", "#{base_id}-\\d+$")).exists?
        max_count = related_external_ids.pluck(:external_id).map { |related_id| related_id.scan(/\d+$/).first.to_i }.max
        "#{base_id}-#{max_count + 1}"
      elsif self.class.exists?(external_id: base_id)
        "#{base_id}-1"
      else
        base_id.to_s
      end
    end
  end
end
