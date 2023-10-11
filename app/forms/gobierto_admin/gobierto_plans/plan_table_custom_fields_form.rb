# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoPlans
    class PlanTableCustomFieldsForm < BaseForm
      REQUIRED_COLUMNS = %w(external_id custom_field).freeze
      TRANSFORMATIONS = {
        text: ->(data) { data.to_s },
        integer: ->(data) { data.to_i },
        float: ->(data) { ::GobiertoCommon::CustomFieldValue::Numeric.parse_float(data) },
        date: ->(data) { Date.parse(data) }
      }.with_indifferent_access.freeze

      attr_accessor(
        :plan,
        :csv_file
      )

      validates :plan, :csv_file, presence: true
      validate :csv_file_format

      def initialize(options = {})
        super(options)

        tables_definitions
      end

      def save
        save_table_custom_fields_data if valid?
      end

      private

      def tables_definitions
        @tables_definitions ||=
          ::GobiertoCommon::CustomFieldRecordsForm.new(instance: plan, item: plan.nodes.new).available_custom_fields.plugin.inject({}) do |definitions, custom_field|
            next definitions unless custom_field.configuration.plugin_type == "table"

            definitions.update(
              custom_field.uid => custom_field.configuration["plugin_configuration"]["columns"]
            )
          end
      end

      def save_table_custom_fields_data
        ActiveRecord::Base.transaction do
          import_table_custom_fields
          @plan.touch
        end
      end

      def csv_file_format
        errors.add(:base, :file_not_found) unless csv_file.present?
        errors.add(:base, :invalid_format) unless csv_file_content

        if !csv_file_content || (REQUIRED_COLUMNS - csv_file_headers).present? || csv_file_headers.none? { |header| /col_\d+/.match?(header) }
          errors.add(:base, :invalid_columns)
        end
      end

      def external_id_header
        @external_id_header ||= csv_file_content.headers.intersection(%w(Node.external_id external_id)).first
      end

      def csv_file_headers
        @csv_file_headers ||= csv_file_content.headers.map do |header|
          header.gsub(/\ANode\./, "")
        end
      end

      def import_table_custom_fields
        nodes_data = csv_file_content.inject({}) do |hash, row|
          hash.update(row[external_id_header] => (hash[row[external_id_header]] || []) << row)
        end

        nodes_data.each_pair do |external_id, rows|
          next unless (node = plan.nodes.find_by_external_id external_id).present?

          custom_field_records_values = {}

          rows.each do |row|
            uid = row["custom_field"].parameterize.tr("_", "-")
            next unless (transformed_row = transform_row(row, uid)).present?

            (custom_field_records_values[uid] ||= []) << transformed_row
          end

          custom_fields_form = ::GobiertoCommon::CustomFieldRecordsForm.new(
            site_id: @plan.site.id,
            item: node,
            instance: @plan,
            with_version: true,
            version_index: 0
          )
          custom_fields_form.custom_field_records = custom_field_records_values
          if custom_fields_form.changed?
            custom_fields_form.force_new_version = true
            node.touch
            publish_if_required node
          end
          custom_fields_form.save
        end
      end

      def transform_row(row, uid)
        return unless (config = tables_definitions[uid]).present?

        col_names = config.map { |col| col.fetch("id") }
        transformations = config.map { |col| TRANSFORMATIONS[col.fetch("type")] }
        raw_values = row.to_h.select { |header, _| /col_\d+/i.match?(header) }.values
        transformed_values = transformations.zip(raw_values).map { |(function, value)| value.presence && function.call(value) }
        col_names.zip(transformed_values).to_h
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
        if custom_fields_form.changed?
          custom_fields_form.force_new_version = true
          node.touch
        end

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

      def publish_if_required(node)
        return unless @plan.publish_last_version_automatically?

        node.published!
        node.update_attribute(:published_version, node.versions.count)
      end
    end
  end
end
