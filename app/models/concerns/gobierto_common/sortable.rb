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

      # positions_from_params arg: hash of arrays
      # The element with id 0 defines the order of the parent nodes
      # Example:
      #   {
      #     0: [parent_id_1, parent_id_2],
      #     parent_id_1: [children_id_1, children_id_2],
      #     parent_id_2: [children_id_3, children_id_4]
      #   }
      def self.update_parents_and_positions(positions_from_params)
        child_assignment = {}
        parent_assignment = {}
        positions_from_params.each do |parent_id, children_ids|
          if parent_id == "0"
            children_ids.each_with_index do |child_id, position|
              parent_assignment[child_id] = { position: position, term_id: nil, level: 0 }
            end
          else
            children_ids.each_with_index do |child_id, position|
              child_assignment[child_id] = { position: position, term_id: parent_id }
            end
          end
        end

        update(parent_assignment.keys, parent_assignment.values)
        update(child_assignment.keys, child_assignment.values)
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
