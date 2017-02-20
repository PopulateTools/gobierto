class CensusRepository
  attr_reader(
    :site_id,
    :document_number,
    :document_number_digest,
    :date_of_birth,
    :import_reference
  )

  def self.destroy_previous_by_reference(site_id:, import_reference:)
    CensusItem
      .where(site_id: site_id)
      .where.not(import_reference: import_reference.to_i)
      .delete_all
  end

  def initialize(site_id:, document_number:, date_of_birth:, import_reference: nil)
    @site_id = site_id

    @document_number = document_number.strip.to_s
    @document_number_digest = ::SecretAttribute.digest(@document_number)

    @date_of_birth = parse_date(date_of_birth)

    @import_reference = import_reference
  end

  def valid?
    site_id.present? && document_number_digest.present? && date_of_birth.present?
  end

  def exists?
    CensusItem
      .where(verified: false)
      .where(site_id: site_id)
      .where(document_number_digest: document_number_digest)
      .where(date_of_birth: date_of_birth)
      .exists?
  end

  def create
    census_item.save(validate: false) if valid?
  end

  private

  def census_item
    @census_item ||= CensusItem.new(
      verified: false,
      site_id: site_id,
      document_number_digest: document_number_digest,
      date_of_birth: date_of_birth,
      import_reference: import_reference
    )
  end

  def parse_date(date)
    return nil if date.blank?

    # Validate format
    if date =~ /\A(\d{4})-(\d\d?)-(\d\d?)\z/
      return Date.parse(date)
    elsif date =~ /\A(\d\d?)-(\d\d?)-(\d+)\z/
      day   = $1.to_i
      month = $2.to_i
      year  = $3.to_i
      year  = "19#{year}".to_i if year <= 99
      return Date.new year, month, day
    end
  rescue ArgumentError
    nil
  end

end
