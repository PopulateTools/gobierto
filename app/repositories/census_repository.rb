# frozen_string_literal: true

require_dependency 'secret_attribute'

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

    @document_number = parse_document_number(document_number.to_s)
    @document_number_alternatives = build_alternatives(@document_number)
    @document_number_digest = ::SecretAttribute.digest(@document_number)

    @date_of_birth = parse_date(date_of_birth)

    @import_reference = import_reference
  end

  def valid?
    site_id.present? && document_number_digest.present? && date_of_birth.present?
  end

  def exists?
    census_items = CensusItem
                   .where(verified: false)
                   .where(site_id: site_id)
                   .where(date_of_birth: date_of_birth)
                   .where(document_number_digest: document_number_digest)

    if @document_number_alternatives.any?
      @document_number_alternatives.each do |alternative|
        census_items = census_items.or(CensusItem.where(document_number_digest: ::SecretAttribute.digest(alternative)))
      end
    end

    census_items.exists?
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
    return date if date.is_a?(Date)

    # Validate format
    if date.match?(/\A(\d{4})-(\d\d?)-(\d\d?)\z/)
      return Date.parse(date)
    elsif date =~ /\A(\d\d?)-(\d\d?)-(\d+)\z/
      day   = Regexp.last_match(1).to_i
      month = Regexp.last_match(2).to_i
      year  = Regexp.last_match(3).to_i
      year  = "19#{year}".to_i if year <= 99
      return Date.new year, month, day
    end
  rescue ArgumentError
    nil
  end

  def parse_document_number(document_number)
    parsed_document_number = document_number

    parsed_document_number.delete!(' ')
    parsed_document_number.gsub!(/\W/, '')
    parsed_document_number.upcase!

    parsed_document_number
  end

  def build_alternatives(document_number)
    alternatives = []
    document_number = document_number.upcase
    alternatives.push(document_number)

    case document_number
      when /\A\d+([a-z])\z/i
        letter = Regexp.last_match(1)
        alternatives.push(document_number.tr(letter, ''))
        alternatives.push('X' + document_number)
        alternatives.push('X' + document_number.tr(letter, ''))
      when /\AX0\d+([a-z])\z/i
        letter = Regexp.last_match(1)
        alternatives.push(document_number.tr(letter, ''))
        alternatives.push(document_number.tr('X0', 'X'))
        alternatives.push(document_number.tr('X0', 'X').tr(letter, ''))
        alternatives.push(document_number.tr('X0', '0'))
        alternatives.push(document_number.tr('X0', '0').tr(letter, ''))
        alternatives.push(document_number.tr('X0', ''))
        alternatives.push(document_number.tr('X0', '').tr(letter, ''))
      when /\AX\d+([a-z])\z/i
        letter = Regexp.last_match(1)
        alternatives.push(document_number.tr(letter, ''))
        alternatives.push(document_number.gsub('X', 'X0'))
        alternatives.push(document_number.tr(letter, '').gsub('X', 'X0'))
        alternatives.push(document_number.tr('X', '0'))
        alternatives.push(document_number.tr(letter, '').tr('X', '0'))
        alternatives.push(document_number.tr('X', ''))
        alternatives.push(document_number.tr(letter, '').tr('X', ''))
      when /\AX0\d+\z/i
        alternatives.push(document_number.tr('X0', 'X'))
        alternatives.push(document_number.tr('X0', '0'))
        alternatives.push(document_number.tr('X0', ''))
      when /\AX\d+\z/i
        alternatives.push(document_number.gsub('X', 'X0'))
        alternatives.push(document_number.tr('X', '0'))
        alternatives.push(document_number.tr('X', ''))
    end

    alternatives
  end
end
