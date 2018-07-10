# frozen_string_literal: true

require "test_helper"

class AsymmetricEncryptorTest < Minitest::Test
  include AsymmetricEncryptorHelpers

  def testing_encryptor
    stub_application_secrets_with_test_certificate
    AsymmetricEncryptor.new('test_certificate')
  end

  def test_invalid_with_key_not_defined_in_secrets
    assert_raises(ArgumentError) do
      AsymmetricEncryptor.new('invalid_name')
    end
  end

  def test_encrypt_returns_always_the_same
    first_encryption = testing_encryptor.encrypt('whadawhaa?')
    second_encryption = testing_encryptor.encrypt('whadawhaa?')

    assert_equal(first_encryption, second_encryption)

  end

  def test_padding
    assert_equal(testing_encryptor.padding('test').length, 256)
  end

end
