# frozen_string_literal: true

require_dependency 'asymmetric_encryptor'

class User::Verification::IdNumber < User::Verification
  before_save :encrypt_id_number

  validate :encryption_values_must_be_present

  attr_accessor :id_number

  default_scope -> { where(verification_type: 'id_number') }

  def id_number=(id_number)
    @id_number = id_number
    valid? if encryption_key.present?
  end

  def document_type=(document_type)
    verification_data["document_type"] = document_type
  end

  def document_type
    verification_data["document_type"]
  end

  def encryption_key
    verification_data['encryption_key']
  end

  def encryption_key=(encryption_key)
    verification_data['encryption_key'] = encryption_key
    valid? if id_number.present?
  end

  def encrypted_id_number
    verification_data['encrypted_id_number'] ||= encrypt_id_number
  end

  def encrypted_id_number=(encrypted_id_number)
    verification_data['encrypted_id_number'] = encrypted_id_number
  end

  def encryption_values_must_be_present
    if encryption_key.blank? || encrypted_id_number.blank? && id_number.blank?
      errors.add(:base, :invalid)
    end
  end

  def encrypt_id_number
    id_number.present? ? AsymmetricEncryptor.new(encryption_key).encrypt(id_number) : nil
  end
end
