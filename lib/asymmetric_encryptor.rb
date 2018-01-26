# frozen_string_literal: true

class AsymmetricEncryptor
  def initialize(key_name)
    @key_string = Rails.application.secrets.send(key_name)
    raise ArgumentError.new("Unknown key: #{key_name}") if @key_string.blank?
    @public_key = OpenSSL::PKey::RSA.new(@key_string)
    @padding_size = @public_key.n.num_bytes
  end

  def padding(string)
    string.rjust(@padding_size, string)
  end

  def encrypt(string)
    @public_key.public_encrypt(padding(string), OpenSSL::PKey::RSA::NO_PADDING)
  end
end
