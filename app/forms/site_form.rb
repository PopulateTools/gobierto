class SiteForm
  include ActiveModel::Model

  attr_accessor(
    :id,
    :external_id,
    :name,
    :domain,
    :configuration_data,
    :location_name,
    :location_type,
    :institution_url,
    :institution_type,
    :institution_email,
    :institution_address,
    :institution_document_number,
    :head_markup,
    :foot_markup,
    :created_at,
    :updated_at
  )

  validates :name, presence: true
  validates :location_name, presence: true
  validates :domain, presence: true, domain: true

  delegate :persisted?, to: :site

  def save
    save_site if valid?
  end

  def site
    @site ||= Site.find_by(id: id).presence || build_site
  end

  private

  def build_site
    Site.new
  end

  def save_site
    @site = site.tap do |site_attributes|
      site_attributes.name                        = name
      site_attributes.domain                      = domain
      site_attributes.configuration_data          = configuration_data
      site_attributes.location_name               = location_name
      site_attributes.location_type               = location_type
      site_attributes.institution_url             = institution_url
      site_attributes.institution_type            = institution_type
      site_attributes.institution_email           = institution_email
      site_attributes.institution_address         = institution_address
      site_attributes.institution_document_number = institution_document_number
    end

    if @site.valid?
      @site.save
    else
      promote_errors(@site.errors)

      false
    end
  end

  protected

  def promote_errors(errors)
    errors.each do |attribute, message|
      errors.add(attribute, message)
    end
  end
end
