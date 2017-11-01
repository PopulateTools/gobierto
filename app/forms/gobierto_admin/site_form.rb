module GobiertoAdmin
  class SiteForm
    include ActiveModel::Model

    GOOGLE_ANALYTICS_ID_REGEXP = /\AUA-\d{4,10}-\d{1,4}\z/

    attr_accessor(
      :id,
      :external_id,
      :title_translations,
      :name_translations,
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
      :links_markup,
      :site_modules,
      :visibility_level,
      :google_analytics_id,
      :username,
      :password,
      :created_at,
      :updated_at,
      :creation_ip,
      :municipality_id,
      :logo_file,
      :available_locales,
      :default_locale,
      :privacy_page_id,
      :populate_data_api_token,
      :home_page
    )

    attr_reader :logo_url

    delegate :persisted?, to: :site

    validates :google_analytics_id,
      format: { with: GOOGLE_ANALYTICS_ID_REGEXP },
      allow_nil: true,
      allow_blank: true

    validates :username, :password, presence: true, if: :draft_visibility?
    validates :title_translations, presence: true
    validates :name_translations, presence: true
    validates :available_locales, length: { minimum: 1 }
    validates :default_locale, presence: true
    validates :home_page, presence: true

    def save
      save_site if valid?
    end

    def site
      @site ||= Site.find_by(id: id).presence || build_site
    end

    def site_modules
      @site_modules ||= site.configuration.modules
    end

    def head_markup
      @head_markup ||= site.configuration.head_markup
    end

    def foot_markup
      @foot_markup ||= site.configuration.foot_markup
    end

    def links_markup
      @links_markup ||= site.configuration.links_markup
    end

    def google_analytics_id
      @google_analytics_id ||= site.configuration.google_analytics_id
    end

    def username
      @username ||= site.configuration.password_protection_username
    end

    def password
      @password ||= site.configuration.password_protection_password
    end

    def available_locales
      @available_locales ||= site.configuration.available_locales
    end

    def default_locale
      @default_locale ||= site.configuration.default_locale
    end

    def home_page
      @home_page ||= site.configuration.home_page
    end

    def visibility_level
      @visibility_level ||= "draft"
    end

    def privacy_page_id
      @privacy_page_id ||= site.configuration.privacy_page_id
    end

    def populate_data_api_token
      @populate_data_api_token ||= site.configuration.populate_data_api_token
    end

    def logo_url
      @logo_url ||= begin
        return site.configuration.logo unless logo_file.present?

        FileUploadService.new(
          site: site,
          collection: site.model_name.collection,
          attribute_name: :logo,
          file: logo_file
        ).call
      end
    end

    private

    def build_site
      Site.new
    end

    def save_site
      @site = site.tap do |site_attributes|
        site_attributes.title_translations = title_translations
        site_attributes.name_translations = name_translations
        site_attributes.domain = domain
        site_attributes.location_name = location_name
        site_attributes.municipality_id = municipality_id
        site_attributes.location_type = location_type
        site_attributes.institution_url = institution_url
        site_attributes.institution_type = institution_type
        site_attributes.institution_email = institution_email
        site_attributes.institution_address = institution_address
        site_attributes.institution_document_number = institution_document_number
        site_attributes.visibility_level = visibility_level
        site_attributes.creation_ip = creation_ip
        site_attributes.configuration.home_page = home_page
        site_attributes.configuration.modules = (site_modules.append(home_page)).uniq
        site_attributes.configuration.logo = logo_url
        site_attributes.configuration.head_markup = head_markup
        site_attributes.configuration.foot_markup = foot_markup
        site_attributes.configuration.links_markup = links_markup
        site_attributes.configuration.google_analytics_id = google_analytics_id
        site_attributes.configuration.password_protection_username = username
        site_attributes.configuration.password_protection_password = password
        site_attributes.configuration.default_locale = default_locale
        site_attributes.configuration.available_locales = (available_locales.select{ |l| l.present? } + [default_locale]).uniq
        site_attributes.configuration.privacy_page_id = privacy_page_id
        site_attributes.configuration.populate_data_api_token = populate_data_api_token
      end

      if @site.valid?
        @site.save
      else
        promote_errors(@site.errors)

        false
      end
    end

    def draft_visibility?
      visibility_level == "draft"
    end

    protected

    def promote_errors(errors_hash)
      errors_hash.each do |attribute, message|
        errors.add(attribute, message)
      end
    end
  end
end
