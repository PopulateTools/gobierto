# frozen_string_literal: true

module GobiertoAdmin
  class SiteForm < BaseForm

    GOOGLE_ANALYTICS_ID_REGEXP = /\AUA-\d{4,10}-\d{1,4}\z/

    attr_accessor(
      :id,
      :title_translations,
      :name_translations,
      :domain,
      :configuration_data,
      :organization_name,
      :organization_url,
      :organization_type,
      :organization_email,
      :organization_address,
      :organization_document_number,
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
      :organization_id,
      :logo_file,
      :available_locales,
      :default_locale,
      :privacy_page_id,
      :populate_data_api_token,
      :home_page,
      :home_page_item_id,
      :raw_configuration_variables,
      :auth_modules
    )

    attr_reader :logo_url

    attr_writer :engine_overrides

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
    validates :organization_name, presence: true

    def save
      if valid? && save_site
        after_save_callback
        return site
      end
    end

    def site
      @site ||= Site.find_by(id: id).presence || build_site
    end

    def site_modules
      @site_modules ||= site.configuration.modules
    end

    def auth_modules
      @auth_modules = if @auth_modules
                        @auth_modules & AUTH_MODULES.select do |auth_module|
                          domains = auth_module.domains
                          !domains || domains.include?(site.domain)
                        end.map(&:name)
                      else
                        site.configuration.auth_modules
                      end
    end

    def engine_overrides_param=(engine_overrides)
      if engine_overrides.is_a? String
        engine_overrides = engine_overrides.split(/[;,\s]+/)
      end
      engine_overrides_base_path = Rails.root.join("vendor/gobierto_engines/")
      @engine_overrides = engine_overrides.select do |engine|
        Dir.exist?(File.join(engine_overrides_base_path, engine))
      end
    end

    def engine_overrides
      @engine_overrides ||= site.configuration.engine_overrides
    end

    def engine_overrides_param
      @engine_overrides_param ||= engine_overrides.join(", ")
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

    def home_page_item_id
      @home_page_item_id ||= site.configuration.home_page_item_id
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

    def raw_configuration_variables
      @raw_configuration_variables ||= site.configuration.raw_configuration_variables
    end

    def logo_url
      @logo_url ||= begin
        return site.configuration.logo unless logo_file.present?

        GobiertoAdmin::FileUploadService.new(
          site: site,
          collection: site.model_name.collection,
          attribute_name: :logo,
          file: logo_file
        ).upload!
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
        site_attributes.organization_name = organization_name
        site_attributes.organization_id = organization_id
        site_attributes.organization_url = organization_url
        site_attributes.organization_type = organization_type
        site_attributes.organization_email = organization_email
        site_attributes.organization_address = organization_address
        site_attributes.organization_document_number = organization_document_number
        site_attributes.visibility_level = visibility_level
        site_attributes.creation_ip = creation_ip
        site_attributes.configuration.home_page = home_page
        site_attributes.configuration.home_page_item_id = home_page_item_id
        site_attributes.configuration.modules = site_modules
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
        site_attributes.configuration.raw_configuration_variables = raw_configuration_variables
        site_attributes.configuration.auth_modules = auth_modules
        site_attributes.configuration.engine_overrides = engine_overrides
      end

      @organization_id_changed = @site.organization_id_changed?

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

    def organization_id_changed?
      @organization_id_changed
    end

    protected

    def after_save_callback
      ::GobiertoBudgets::GenerateAnnualLinesJob.perform_later(@site) if organization_id_changed?
    end

  end
end
