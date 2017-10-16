# frozen_string_literal: true

require "test_helper"

class SecretAttributeTest < Minitest::Test

  def test_digest
    subject = SecretAttribute.digest("wadus")

    assert_kind_of String, subject
    assert_equal SecretAttribute.digest("wadus"), subject
  end

  def test_encrypt_and_decrypt
    plain_text = 'My secret text'

    cypher_text = SecretAttribute.encrypt(plain_text)

    assert_kind_of String, cypher_text
    refute_equal plain_text, cypher_text

    decrypted_text = SecretAttribute.decrypt(cypher_text)

    assert_equal plain_text, decrypted_text
  end

end
