# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class PlanDataForm < BaseForm
      class CSVRowInvalid < ArgumentError; end

      REQUIRED_COLUMNS = %w(Node.Title Node.Status).freeze

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
      rescue CSVRowInvalid => e
        errors.add(:base, :invalid_row, row_data: e.message)
        return false
      end

      def csv_file_format
        errors.add(:base, :file_not_found) unless csv_file.present?
        errors.add(:base, :invalid_format) unless csv_file_content
        unless !csv_file_content || (REQUIRED_COLUMNS - csv_file_content.headers).blank? && csv_file_content.headers.any? { |header| /Level \d+/.match?(header) }
          errors.add(:base, :invalid_columns)
        end
      end

      def clear_previous_data
        node_class.joins(:categories).where("#{ categories_table }.plan_id = ?", @plan.id).destroy_all
        @plan.categories.destroy_all
      end

      def import_nodes
        csv_file_content.each do |row|
          row_decorator = ::GobiertoPlans::RowNodeDecorator.new(row, plan: @plan)
          row_decorator.categories.each do |category|
            raise CSVRowInvalid, row_decorator.to_csv unless category.save
          end
          if (node = row_decorator.node).present?
            raise CSVRowInvalid, row_decorator.to_csv unless REQUIRED_COLUMNS.all? { |column| row_decorator[column].present? } && node.save
          end
        end
      end

      def calculate_cached_data
        category_class.where(plan_id: @plan.id).each do |category|
          category.progress = category.children_progress
          category.uid = category.calculate_uid
          category.save
        end
      end

      def col_sep
        separators = [",", ";"]
        first_line = csv_file.open.first
        separators.max do |a, b|
          first_line.split(a).count <=> first_line.split(b).count
        end
      end

      def csv_file_content
        @csv_file_content ||= begin
                                ::CSV.read(csv_file.open, headers: true, col_sep: col_sep)
                              rescue ArgumentError, CSV::MalformedCSVError
                                false
                              end
      end
    end
  end
end
