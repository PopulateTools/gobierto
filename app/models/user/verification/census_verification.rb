class User::Verification::CensusVerification < User::Verification
  default_scope -> { where(verification_type: "census") }

  def verification_type
    "census"
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

  private

  def census_repository
    @census_repository ||= CensusRepository.new(
      site_id: site_id,
      document_number: document_number,
      date_of_birth: date_of_birth
    )
  end
end
