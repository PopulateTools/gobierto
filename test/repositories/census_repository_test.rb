# frozen_string_literal: true

require "test_helper"

class CensusRepositoryTest < ActiveSupport::TestCase
  def census_repository
    @census_repository ||= CensusRepository.new(
      site_id: site.id,
      document_number: "Wadus001",
      date_of_birth: "1-1-2000",
      import_reference: 1
    )
  end

  def site
    @site ||= sites(:madrid)
  end

  def census_item
    @census_item ||= census_items(:madrid_92)
  end

  def test_valid?
    assert census_repository.valid?
  end

  def test_destroy_previous_by_reference
    census_repository.create

    assert_difference "CensusItem.count", -5 do
      CensusRepository.destroy_previous_by_reference(
        site_id: census_repository.site_id,
        import_reference: 1
      )
    end

    CensusRepository.new(
      site_id: site.id,
      document_number: "wadus",
      date_of_birth: "2000-01-02",
      import_reference: 2
    ).create

    assert_difference "CensusItem.count", -1 do
      CensusRepository.destroy_previous_by_reference(
        site_id: site.id,
        import_reference: 2
      )
    end
  end

  def test_parse_document_number
    document_numbers = ["12345678A", " 1234 5678 a ", "ñ1?23 45*6¿78--a"]

    document_numbers.each do |document_number|
      census_repository = CensusRepository.new(
        site_id: site.id,
        document_number: document_number,
        date_of_birth: "2000-01-02"
      )

      assert_equal census_repository.document_number, "12345678A"
    end
  end

  def test_exists?
    refute census_repository.exists?

    existing_census_repository = CensusRepository.new(
      site_id: census_item.site_id,
      document_number: "00000000A",
      date_of_birth: census_item.date_of_birth
    )

    assert existing_census_repository.exists?
  end

  def test_exists_with_no_letter?
    existing_census_repository = CensusRepository.new(
      site_id: census_item.site_id,
      document_number: "12345678",
      date_of_birth: Date.parse("1998-01-01")
    )

    assert existing_census_repository.exists?

    existing_census_repository = CensusRepository.new(
      site_id: census_item.site_id,
      document_number: "12345678A",
      date_of_birth: Date.parse("1998-01-01")
    )

    assert existing_census_repository.exists?
  end

  def test_exists_with_special_letters
    existing_census_repository = CensusRepository.new(
      site_id: census_item.site_id,
      document_number: "x5104959v",
      date_of_birth: Date.parse("1998-01-01")
    )

    assert existing_census_repository.exists?

    existing_census_repository = CensusRepository.new(
      site_id: census_item.site_id,
      document_number: "x05104959v",
      date_of_birth: Date.parse("1998-01-01")
    )

    assert existing_census_repository.exists?

    existing_census_repository = CensusRepository.new(
      site_id: census_item.site_id,
      document_number: "05104959v",
      date_of_birth: Date.parse("1998-01-01")
    )

    assert existing_census_repository.exists?

    existing_census_repository = CensusRepository.new(
      site_id: census_item.site_id,
      document_number: "x05104959",
      date_of_birth: Date.parse("1998-01-01")
    )

    assert existing_census_repository.exists?

    existing_census_repository = CensusRepository.new(
      site_id: census_item.site_id,
      document_number: "X5104959",
      date_of_birth: Date.parse("1998-01-01")
    )

    assert existing_census_repository.exists?
  end

  def test_create
    assert_difference "CensusItem.count", 1 do
      census_repository.create
    end

    census_item = CensusItem.order(id: :desc).first

    refute census_item.verified
    assert census_repository.site_id, census_item.site_id
    assert census_repository.document_number_digest, census_item.document_number_digest
    assert census_repository.date_of_birth, census_item.date_of_birth
    assert census_repository.import_reference, census_item.import_reference
  end
end
