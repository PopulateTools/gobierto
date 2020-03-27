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

    def scoped_new_external_id(relation = nil)
      relation ||= self.class.all

      base_id = (relation.where.not(external_id: nil).count + 1).to_s
      return base_id unless relation.where(external_id: base_id).exists?

      max_numeric_external_id = relation.where("external_id ~* ?", "^\\d+$").pluck(:external_id).map(&:to_i).max

      return (max_numeric_external_id + 1).to_s unless max_numeric_external_id.blank? || relation.where(external_id: max_numeric_external_id + 1).exists?

      new_external_id
    end
  end
end
