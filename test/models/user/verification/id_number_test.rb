# frozen_string_literal: true

require "test_helper"

class User::Verification::IdNumberTest < ActiveSupport::TestCase
  include AsymmetricEncryptorHelpers

  def dennis_verification
    @dennis_verification ||= user_verification_id_numbers(:dennis_id_number)
  end

  def blank_verification_without_encryption_key
    @blank_verification_without_encryption_key ||= User::Verification::IdNumber.new
  end

  def blank_verification_with_encryption_key
    with_stubbed_application_secrets do
      @blank_verification_with_encryption_key ||= User::Verification::IdNumber.new(encryption_key: 'test_certificate')
    end
  end

  def test_valid
    assert dennis_verification.valid?
  end

  def test_invalid_without_id_number_or_encrypted_id_number
    refute blank_verification_with_encryption_key.valid?
  end

  def test_invalid_without_encryption_key
    blank_verification_without_encryption_key.id_number = '01234567X'
    refute blank_verification_without_encryption_key.valid?
  end

  def test_valid_with_id_number
    blank_verification_with_encryption_key.id_number = '01234567X'
    assert blank_verification_with_encryption_key.valid?
  end

  def test_verification_data_valid
    id_number = '01234567X'
    encrypted_id_number = testing_asymmetric_encryptor.encrypt(id_number)
    blank_verification_with_encryption_key.id_number = id_number
    assert_equal encrypted_id_number, blank_verification_with_encryption_key.encrypted_id_number
  end

  def test_id_number_is_not_stored
    id_number = '01234567X'
    encrypted_id_number = testing_asymmetric_encryptor.encrypt(id_number)
    blank_verification_with_encryption_key.id_number = id_number
    refute_equal id_number, blank_verification_with_encryption_key.encrypted_id_number
  end
end
