class Admin::AdminForm
  include ActiveModel::Model

  attr_accessor(
    :id,
    :name,
    :email,
    :password,
    :password_digest,
    :confirmation_token,
    :reset_password_token,
    :authorization_level,
    :sites,
    :site_ids,
    :site_modules,
    :created_at,
    :updated_at,
    :creation_ip,
    :last_sign_in_at,
    :last_sign_in_ip
  )

  delegate :persisted?, :to_model, to: :admin

  def save
    save_admin if valid?
  end

  def admin
    @admin ||= Admin.find_by(id: id).presence || build_admin
  end

  def authorization_level
    @authorization_level ||= "regular"
  end

  def site_modules
    @site_modules ||= []
  end

  def sites
    @sites ||= Site.where(id: site_ids)
  end

  def site_ids
    @site_ids ||= admin.sites.map(&:id)
  end

  private

  def build_admin
    Admin.new
  end

  def save_admin
    @admin = admin.tap do |admin_attributes|
      admin_attributes.name = name
      admin_attributes.email = email
      admin_attributes.password = password if password
      admin_attributes.authorization_level = authorization_level
      admin_attributes.creation_ip = creation_ip
    end

    if @admin.valid?
      ActiveRecord::Base.transaction do
        @admin.save
        @admin.sites = sites
      end
    else
      promote_errors(@admin.errors)

      false
    end
  end

  protected

  def promote_errors(errors_hash)
    errors_hash.each do |attribute, message|
      errors.add(attribute, message)
    end
  end
end
