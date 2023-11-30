# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class PlanDataForm < BaseForm
      include ::GobiertoAdmin::PermissionsGroupHelpers
      include ::GobiertoPlans::VersionsHelpers

      class CSVRowInvalid < ArgumentError; end
      class StatusMissing < ArgumentError; end
      class ExternalIdTaken < ArgumentError; end
      class CategoryNotFound < ArgumentError; end

      REQUIRED_COLUMNS = %w(Node.Title).freeze

      attr_accessor(
        :plan,
        :csv_file
      )

      validates :plan, :csv_file, presence: true
      validate :csv_file_format

      delegate :site, to: :plan

      def initialize(options = {})
        super(options)
        @has_previous_nodes = @plan.nodes.exists?
      end

      def save
        save_plan_data if valid?
      end

      private

      def has_previous_nodes?
        @has_previous_nodes
      end

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
            clear_categories_vocabulary unless has_previous_nodes?
            import_nodes
            @plan.touch
          end
        end
      rescue CSVRowInvalid => e
        errors.add(:base, :invalid_row, row_data: e.message)
        false
      rescue StatusMissing, ExternalIdTaken, CategoryNotFound => e
        errors.add(:base, e.class.name.demodulize.underscore.to_sym, row_data: e.message)
        false
      rescue ::GobiertoCommon::PlainCustomFieldValueDecorator::TermNotFound => e
        errors.add(:base, e.class.name.demodulize.underscore.to_sym, JSON.parse(e.message).symbolize_keys)
        false
      rescue ActiveRecord::RecordNotDestroyed
        errors.add(:base, :used_resource)
        false
      end

      def csv_file_format
        errors.add(:base, :file_not_found) unless csv_file.present?
        errors.add(:base, :invalid_format) unless csv_file_content
        unless !csv_file_content || (REQUIRED_COLUMNS - csv_file_content.headers).blank? && csv_file_content.headers.any? { |header| /Level \d+/.match?(header) }
          errors.add(:base, :invalid_columns)
        end
      end

      def clear_categories_vocabulary
        if @plan.categories_vocabulary.blank?
          @plan.create_categories_vocabulary(name_translations: @plan.title_translations, site: @plan.site)
          @plan.save
        end
        @plan.categories_vocabulary.terms.destroy_all
      end

      def import_nodes
        position_counter = 0
        csv_file_content.each do |row|
          row_decorator = ::GobiertoPlans::RowNodeDecorator.new(row, plan: @plan, allow_custom_fields_terms_creation: !has_previous_nodes?)

          raise CategoryNotFound, row_decorator.to_csv if has_previous_nodes? && row_decorator.new_categories?

          row_decorator.categories.each do |category|
            next unless category.new_record?

            category.position = position_counter
            raise CSVRowInvalid, row_decorator.to_csv unless category.name.present? && category.save

            position_counter += 1
          end
          next unless (node = row_decorator.node).present?

          raise ExternalIdTaken, row_decorator.to_csv if row_decorator.external_id_taken?
          node.moderation.site = @plan.site
          raise CSVRowInvalid, row_decorator.to_csv unless REQUIRED_COLUMNS.all? { |column| row_decorator[column].present? } && node.save
          raise StatusMissing, row_decorator.to_csv if row_decorator.status_missing

          save_custom_fields(row_decorator)
          set_publication(node)
          set_permissions_group(node, action_name: :edit)
        end
      end

      def save_custom_fields(row_decorator)
        node = row_decorator.node

        custom_fields_form = ::GobiertoCommon::CustomFieldRecordsForm.new(
          site_id: @plan.site.id,
          item: node,
          instance: @plan,
          with_version: true,
          version_index: 0
        )

        custom_fields_form.custom_field_records = row_decorator.custom_field_records_values
        new_version = has_previous_nodes? && (custom_fields_form.changed? || row_decorator.new_node_version?)
        custom_fields_form.force_new_version = new_version
        node.touch if new_version && !row_decorator.new_node_version?

        custom_fields_form.save
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
