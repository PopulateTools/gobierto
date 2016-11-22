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
end
