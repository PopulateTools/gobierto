require "test_helper"
require "csv"

class Admin::CensusImportFormTest < ActiveSupport::TestCase
  def valid_user_census_import_form
    @valid_user_census_import_form ||= Admin::CensusImportForm.new(
      site_id: site.id,
      admin_id: admin.id,
      file: file
    )
  end

  def invalid_user_census_import_form
    @invalid_user_census_import_form ||= Admin::CensusImportForm.new(
      site_id: site.id,
      admin_id: admin.id,
      file: nil
    )
  end

  def admin
    @admin ||= admins(:tony)
  end

  def site
    @site ||= sites(:madrid)
  end

  def user_verification
    @user_verification ||= user_census_verifications(:dennis_verified)
  end

  def test_save_with_valid_attributes
    with_valid_csv do
      assert valid_user_census_import_form.save
    end
  end

  def test_save_with_invalid_attributes
    with_valid_csv do
      refute invalid_user_census_import_form.save
    end
  end

  def test_items_creation
    with_valid_csv do
      assert_difference "CensusItem.count", 1 do
        valid_user_census_import_form.save
      end
    end
  end

  def test_census_import_creation
    with_valid_csv do
      assert_difference "Admin::CensusImport.count", 1 do
        valid_user_census_import_form.save
      end
    end
  end

  def test_user_verifications_recalculation
    assert user_verification.verified

    with_empty_csv do
      assert_performed_jobs 1 do
        valid_user_census_import_form.save
      end
    end

    refute user_verification.reload.verified
  end

  def test_record_count
    with_valid_csv do
      valid_user_census_import_form.save
    end

    assert_equal 3, valid_user_census_import_form.record_count
  end

  private

  def file
    @file ||= begin
      file_mock = MiniTest::Mock.new
      file_mock.expect :present?, true
      file_mock.expect :open, true

      file_mock
    end
  end

  def with_valid_csv
    CSV.stub :read, csv_for(csv_content) do
      yield
    end
  end

  def with_empty_csv
    CSV.stub :read, [] do
      yield
    end
  end

  protected

  def csv_for(csv_body)
    @csv ||= ::CSV.new(csv_body.strip, headers: false)
  end

  def csv_content
    @csv_content ||= <<-CSV
      51000000W,12-05-1975
      49000000W,25-01-1985
      34000000W,04-12-1995
    CSV
  end
end
