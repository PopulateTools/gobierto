# frozen_string_literal: true

module GobiertoAdmin
  class CensusImportForm < BaseForm

    attr_accessor :site_id, :admin_id, :file
    attr_reader :census_items, :census_import, :record_count

    validates :site_id, :admin_id, presence: true
    validate :file_is_present

    def save
      return false unless valid?

      initialize_import

      ActiveRecord::Base.transaction do
        create_census_items
        destroy_previous_census_items
        complete_import
      end

      if (result = census_import.reload.completed?)
        recalculate_user_verifications
      end

      result
    end

    def record_count
      @record_count ||= census_items.size
    end

    private

    def initialize_import
      @census_import = CensusImport.create(
        site_id: site_id,
        admin_id: admin_id
      )
    end

    def create_census_items
      census_items.each(&:create)
    end

    def census_items
      # Sample input file format:
      #
      # 51000000W,12-05-1975
      # 49000000W,25-01-1985
      # 34000000W,04-12-1995

      @census_items ||= file_content.map do |row|
        census_repo = CensusRepository.new(
          site_id: site_id,
          import_reference: census_import.id,
          document_number: row[0],
          date_of_birth: row[1]
        )

        census_repo if census_repo.valid?
      end.compact
    end

    def destroy_previous_census_items
      CensusRepository.destroy_previous_by_reference(
        site_id: site_id,
        import_reference: census_import.id
      )
    end

    def complete_import
      census_import.update_columns(
        imported_records: census_items.size,
        completed: true
      )
    end

    def recalculate_user_verifications
      User::Verification::CensusVerification
        .where(site_id: site_id)
        .find_each(&:verify_later!)
    end

    def file_is_present
      errors.add(:file, :not_available) unless file.present?
    end

    protected

    def file_content
      @file_content ||= begin
                          content = ::CSV.read(file.open, headers: false)
                          first_row = content.dup.first

                          if first_row.is_a?(Array) && first_row.first.present? && first_row.first.include?(";") && !first_row.first.include?(",")
                            ::CSV.read(file.open, headers: false, col_sep: ";")
                          else
                            content
                          end
                        end
    end
  end
end
