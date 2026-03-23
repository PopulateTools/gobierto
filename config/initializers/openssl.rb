# frozen_string_literal: true

# OpenSSL 3.x disables legacy digest algorithms (MD4, MD5) by default.
# The exchanger gem depends on rubyntlm for NTLM authentication,
# which requires these algorithms.
if defined?(OpenSSL::Provider)
  OpenSSL::Provider.load("legacy")
  OpenSSL::Provider.load("default")
end
