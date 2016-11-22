class User::CensusVerificationForm
  include ActiveModel::Model

  DOCUMENT_NUMBER_REGEXP = /\A(ES)?[0-9A-Z][0-9]{7}[0-9A-Z]\z/

  attr_accessor(
    :site_id,
    :user_id,
    :document_number,
    :date_of_birth,
    :creation_ip
  )

  validates :site, :user, presence: true
  validates :date_of_birth, presence: true
  validates :document_number, presence: true,
    format: { with: DOCUMENT_NUMBER_REGEXP }

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      save_census_verification
      save_user
    end
  end

  def user
    @user ||= User.find_by(id: user_id)
  end

  def site
    @site ||= Site.find_by(id: site_id)
  end

  def census_verification
    @census_verification ||= User::Verification::CensusVerification.new
  end

  def verified?
    census_repository.exists?
  end

  private

  def save_census_verification
    @census_verification = census_verification.tap do |census_verification_attributes|
      census_verification_attributes.site = site
      census_verification_attributes.user = user
      census_verification_attributes.creation_ip = creation_ip
      census_verification_attributes.document_number = document_number
      census_verification_attributes.date_of_birth = date_of_birth
      census_verification_attributes.verified = verified?
    end

    if @census_verification.valid?
      @census_verification.save

      @census_verification
    else
      promote_errors(@census_verification.errors)

      false
    end
  end

  def save_user
    return true unless verified?

    user.update_columns(census_verified: true)
  end

  def census_repository
    @census_repository ||= CensusRepository.new(
      site_id: site_id,
      document_number: document_number,
      date_of_birth: date_of_birth
    )
  end

  protected

  def promote_errors(errors_hash)
    errors_hash.each do |attribute, message|
      errors.add(attribute, message)
    end
  end
end
