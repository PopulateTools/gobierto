# frozen_string_literal: true

module AsymmetricEncryptorHelpers
  def stub_application_secrets_with_test_certificate
    Rails.application.secrets.stubs('test_certificate').returns(raw_certificate)
  end

  def testing_asymmetric_encryptor
    stub_application_secrets_with_test_certificate
    AsymmetricEncryptor.new('test_certificate')
  end

  def raw_certificate
    "-----BEGIN PUBLIC KEY-----\nMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAxzgxsH4g96uXKLt/ULfy\ncGZLBKZXFhJBKFV+E+V1pWeHJrP4KdiNQKG2seAwrKPN0uc9Qlh6wTICjYfYIaxV\nrUHcvKaMloW0I1nUsbCuRNm/kVFc8UCxlsYk7iNfQHAYtQbp/JfumhtgNg1FmKbX\nsiMWD3Vzt8DYZ9k7ZjS9n0/x/7c6z2YdheO2hGTSTIXL60rW+M05SU/gsWn0hKfu\nHSbNTr4JnO55duX2uqJ21VS0RRuPrzUpAHeVXRVrEHxL+YsomK/LTE4B80CaF7G8\nBpRDkyk92UReOH6+NIEc4TffThZgitnaA5m4/1toy6/e/DPrGwNYa7wW1I23YG5X\nswIDAQAB\n-----END PUBLIC KEY-----\n"
  end

  def with_stubbed_application_secrets
    stub_application_secrets_with_test_certificate
    yield
  end
end
