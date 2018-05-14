# frozen_string_literal: true

class User::CensusVerificationForm < BaseForm

  attr_accessor(
    :site_id,
    :user_id,
    :document_number,
    :date_of_birth_year,
    :date_of_birth_month,
    :date_of_birth_day,
    :creation_ip,
    :referrer_url
  )

  validates :site, :user, presence: true
  validates :date_of_birth, presence: true
  validates :document_number, presence: true

  def save
    return false unless valid?

    ActiveRecord::Base.transaction do
      save_census_verification
      perform_verification
    end
  end

  def user
    @user ||= User.find_by(id: user_id)
  end

  def site
    @site ||= Site.find_by(id: site_id)
  end

  def date_of_birth
    if date_of_birth_year && date_of_birth_month && date_of_birth_day
      Date.new(
        date_of_birth_year.to_i,
        date_of_birth_month.to_i,
        date_of_birth_day.to_i
      )
    end
  rescue ArgumentError
    nil
  end

  def census_verification
    @census_verification ||= User::Verification::CensusVerification.new
  end

  private

  def save_census_verification
    @census_verification = census_verification.tap do |census_verification_attributes|
      census_verification_attributes.site = site
      census_verification_attributes.user = user
      census_verification_attributes.creation_ip = creation_ip
      census_verification_attributes.document_number = document_number
      census_verification_attributes.date_of_birth = date_of_birth
    end

    if @census_verification.valid?
      @census_verification.save

      @census_verification
    else
      promote_errors(@census_verification.errors)

      false
    end
  end

  def perform_verification
    census_verification.verify!
  end

end
