module GobiertoCommon
  module Sortable
    extend ActiveSupport::Concern

    included do
      def self.update_positions(positions_from_params)
        position_assignment = positions_from_params.values.reduce({}) do |assignment, attributes|
          assignment.merge!({ attributes["id"] => attributes })
        end

        update(position_assignment.keys, position_assignment.values)
      end

      def self.reset_position!
        ActiveRecord::Base.transaction do
          unscope(:order).order(created_at: :asc).each_with_index do |object, index|
            object.update_column(:position, index + 1)
          end
        end
      end
    end
  end
end
