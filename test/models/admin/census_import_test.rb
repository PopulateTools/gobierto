require "test_helper"

class Admin::CensusImportTest < ActiveSupport::TestCase
  def admin_census_import
    @admin_census_import ||= admin_census_imports(:tony_madrid)
  end

  def test_valid
    assert admin_census_import.valid?
  end
end
