# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class CensusImportFormTest < ActiveSupport::TestCase
    def valid_user_census_import_form(file = nil)
      file ||= census_file
      @valid_user_census_import_form ||= CensusImportForm.new(
        site_id: site.id,
        admin_id: admin.id,
        file: file
      )
    end

    def invalid_user_census_import_form
      @invalid_user_census_import_form ||= CensusImportForm.new(
        site_id: site.id,
        admin_id: admin.id,
        file: nil
      )
    end

    def admin
      @admin ||= gobierto_admin_admins(:tony)
    end

    def site
      @site ||= sites(:madrid)
    end

    def user_verification
      @user_verification ||= user_verification_census_verifications(:dennis_verified)
    end

    def census_file
      @census_file ||= Rails.root.join("test/fixtures/files/census.csv")
    end

    def census_file_semicolons
      @census_file_semicolons ||= Rails.root.join("test/fixtures/files/census_semicolons.csv")
    end

    def empty_census_file
      @empty_census_file ||= Rails.root.join("test/fixtures/files/empty_census.csv")
    end

    def test_save_with_valid_attributes
      assert valid_user_census_import_form.save
    end

    def test_save_with_invalid_attributes
      refute invalid_user_census_import_form.save
    end

    def test_items_creation
      assert_difference "CensusItem.count", -1 do
        valid_user_census_import_form.save
      end
    end

    def test_census_import_creation
      assert_difference "CensusImport.count", 1 do
        valid_user_census_import_form.save
      end
    end

    def test_user_verifications_recalculation
      assert user_verification.verified

      assert_performed_jobs 3 do
        valid_user_census_import_form.save
      end

      refute user_verification.reload.verified
    end

    def test_record_count
      valid_user_census_import_form.save

      assert_equal valid_user_census_import_form.record_count, 4
    end

    def test_record_count_semicolons
      valid_user_census_import_form(census_file_semicolons).save

      assert_equal valid_user_census_import_form(census_file_semicolons).record_count, 4
    end
  end
end
