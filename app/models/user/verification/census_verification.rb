# frozen_string_literal: true

class User::Verification::CensusVerification < User::Verification
  default_scope -> { where(verification_type: "census") }

  attr_writer :census_repository_class, :custom_params

  def verification_type
    "census"
  end

  def census_repository_class
    @census_repository_class ||= CensusRepository
  end

  def document_number
    verification_data["document_number"]
  end

  def document_number=(document_number)
    verification_data["document_number"] = document_number
  end

  def date_of_birth
    verification_data["date_of_birth"]
  end

  def date_of_birth=(date_of_birth)
    verification_data["date_of_birth"] = date_of_birth
  end

  def will_verify?
    @will_verify ||= census_repository.exists?
  end

  def document_number_digest
    @document_number_digest ||= SecretAttribute.digest(verification_data["document_number"])
  end

  def verify!
    ActiveRecord::Base.transaction do
      update_columns(verified: will_verify?)
      user.update_columns(site_id: site_id) if will_verify?
      user.update_columns(census_verified: will_verify?)
    end
  end

  def custom_params
    @custom_params ||= {}
  end

  private

  def census_repository
    @census_repository ||= census_repository_class.new(
      **custom_params.merge(
        site_id: site_id,
        document_number: document_number,
        date_of_birth: date_of_birth
      )
    )
  end
end
