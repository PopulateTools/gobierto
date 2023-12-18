# frozen_string_literal: true

module GobiertoAdmin
  module GobiertoCommon
    class VocabularyTermsImportForm < BaseForm
      class CSVRowInvalid < ArgumentError; end
      REQUIRED_COLUMNS = %w(term_id parent_id term_name_ES term_name_CA term_description_ES term_description_CA).freeze

      attr_accessor(
        :vocabulary,
        :csv_file
      )

      validates :vocabulary, :csv_file, presence: true
      validate :csv_format

      delegate :terms, to: :vocabulary

      def save
        import if valid?
      end

      private

      def file_raw_content
        return @csv_file.open unless @csv_file.is_a? String

        File.open(@csv_file)
      end

      def import
        if csv_file.present?
          ActiveRecord::Base.transaction do
            clear_previous_terms
            import_terms_from_csv
          end
        end
      rescue CSVRowInvalid => e
        errors.add(:base, :invalid_row, row_data: e.message)
        false
      end

      def clear_previous_terms
        terms.destroy_all
      end

      def import_terms_from_csv
        position = 0

        csv_content.each do |row|
          position += 1
          term_form = TermForm.new(
            id: terms.find_by(external_id: row["term_id"]&.strip)&.id,
            site_id: vocabulary.site_id,
            vocabulary_id: vocabulary.id,
            name_translations: extract_translated_attribute(row, "term_name").presence,
            description_translations: extract_translated_attribute(row, "term_description").presence,
            slug: row["term_id"]&.strip,
            external_id: row["term_id"]&.strip
          )

          if term_form.valid?
            term_form.reset_term_id = true
            term_form.term_id = extract_parent_id(row["parent_id"]&.strip)
          end

          unless term_form.save
            promote_errors(term_form.errors)

            raise CSVRowInvalid, row
          end

          term_form.term.update_attribute(:position, position)
        end
      end

      def extract_translated_attribute(row, prefix)
        row.select { |col_name, translation| /\A#{prefix}_/.match?(col_name) && translation.present? }.to_h.transform_keys { |e| e[/[A-Z]+\z/].downcase }
      end

      def extract_parent_id(external_id)
        return unless external_id.present?

        (terms.find_by(external_id: external_id) || terms.create(external_id: external_id, name: "unknown"))&.id
      end

      def csv_format
        errors.add(:base, :file_not_found) unless csv_file.present?
        errors.add(:base, :invalid_format) unless csv_content
        unless !csv_content || (REQUIRED_COLUMNS - csv_content.headers).blank?
          errors.add(:base, :invalid_columns)
        end
      end

      def col_sep
        separators = [",", ";"]
        first_line = file_raw_content.first
        separators.max do |a, b|
          first_line.split(a).count <=> first_line.split(b).count
        end
      end

      def csv_content
        @csv_content ||= begin
                           ::CSV.read(file_raw_content, headers: true, col_sep: col_sep)
                         rescue ArgumentError, CSV::MalformedCSVError
                           false
                         end
      end
    end
  end
end
