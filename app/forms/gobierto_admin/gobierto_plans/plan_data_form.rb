# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class PlanDataForm < BaseForm

      attr_accessor(
        :plan,
        :csv_file
      )

      validates :plan, :csv_file, presence: true
      validate :csv_file_format

      def save
        save_plan_data if valid?
      end

      private

      def plan_class
        ::GobiertoPlans::Plan
      end

      def node_class
        ::GobiertoPlans::Node
      end

      def category_class
        ::GobiertoPlans::Category
      end

      def categories_table
        category_class.table_name
      end

      def save_plan_data
        if csv_file.present?
          ActiveRecord::Base.transaction do
            clear_previous_data
            import_nodes
            calculate_cached_data
          end
        end
        # Add some kind of rescue from invalid resources
      end

      def csv_file_format
        # Pending
      end

      def clear_previous_data
        node_class.joins(:categories).where("#{ categories_table }.plan_id = ?", @plan.id).destroy_all
        @plan.categories.destroy_all
      end

      def import_nodes
        csv_file_content.each do |row|
          row_decorator = ::GobiertoPlans::RowNodeDecorator.new(row, @plan)
          row_decorator.categories.each(&:save)
          row_decorator.node.save
        end
      end

      def calculate_cached_data
        category_class.where(plan_id: @plan.id).each do |category|
          category.progress = category.children_progress
          category.uid = category.calculate_uid
          category.save
        end
      end

      def csv_file_content
        @csv_file_content ||= begin
                                ::CSV.read(csv_file.open, headers: true)
                              end
      end
    end
  end
end
