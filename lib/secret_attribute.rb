# frozen_string_literal: true

require 'digest/sha1'

class SecretAttribute
  def self.digest(value)
    Digest::SHA1.hexdigest(value + salt)
  end

  def self.salt
    Rails.application.secrets.secret_key_base
  end
  private_class_method :salt
end
