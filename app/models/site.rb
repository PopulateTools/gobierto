class Site < ApplicationRecord
  RESERVED_SUBDOMAINS = %W(presupuestos hosted)

  has_many :activities

  # GobiertoAdmin integrations
  has_many :admin_sites, dependent: :destroy, class_name: "GobiertoAdmin::AdminSite"
  has_many :admins, through: :admin_sites, class_name: "GobiertoAdmin::Admin"
  has_many :census_imports, dependent: :destroy, class_name: "GobiertoAdmin::CensusImport"

  # GobiertoCommon integration
  has_many :collections, dependent: :destroy, class_name: "GobiertoCommon::Collection"
  has_many :collection_items, as: :container, class_name: "GobiertoCommon::CollectionItem", dependent: :destroy

  has_many :content_blocks, dependent: :destroy, class_name: "GobiertoCommon::ContentBlock"
  has_many :custom_user_fields, dependent: :destroy, class_name: "GobiertoCommon::CustomUserField"

  has_many :scopes, dependent: :destroy, class_name: "GobiertoCommon::Scope"

  # User integrations
  has_many :subscriptions, dependent: :destroy, class_name: "User::Subscription"
  has_many :notifications, dependent: :destroy, class_name: "User::Notification"

  # GobiertoBudgets integration
  has_many :custom_budget_lines_categories, dependent: :destroy, class_name: "GobiertoBudgets::Category"

  # GobiertoBudgetConsultations integration
  has_many :budget_consultations, dependent: :destroy, class_name: "GobiertoBudgetConsultations::Consultation"
  has_many :budget_consultation_responses, through: :budget_consultations, source: :consultation_responses, class_name: "GobiertoBudgetConsultations::ConsultationResponse"

  # GobiertoPeople integration
  has_many :people, dependent: :destroy, class_name: "GobiertoPeople::Person"
  has_many :person_posts, through: :people, source: :posts, class_name: "GobiertoPeople::PersonPost"
  has_many :person_statements, through: :people, source: :statements, class_name: "GobiertoPeople::PersonStatement"

  # GobiertoCalendars integration
  has_many :events, class_name: "GobiertoCalendars::Event", dependent: :destroy

  # Gobierto CMS integration
  has_many :pages, dependent: :destroy, class_name: "GobiertoCms::Page"
  has_many :sections, dependent: :destroy, class_name: "GobiertoCms::Section"

  # Gobierto Attachments integration
  has_many :attachments, dependent: :destroy, class_name: "GobiertoAttachments::Attachment"

  # Modules settings
  has_many :module_settings, dependent: :destroy, class_name: "GobiertoModuleSettings"

  # Gobierto Participation integration
  has_many :issues, -> { sorted }, dependent: :destroy, class_name: "Issue"
  has_many :processes, dependent: :destroy, class_name: "GobiertoParticipation::Process"
  has_many :contribution_containers, dependent: :destroy, class_name: "GobiertoParticipation::ContributionContainer"
  has_many :contributions, dependent: :destroy, class_name: "GobiertoParticipation::Contribution"
  has_many :comments, dependent: :destroy, class_name: "GobiertoParticipation::Comment"
  has_many :flags, dependent: :destroy, class_name: "GobiertoParticipation::Flag"

  serialize :configuration_data

  before_save :store_configuration
  before_create :initialize_admins
  after_save :run_seeder

  validates :title, presence: true
  validates :domain, presence: true, uniqueness: true, domain: true
  validate :location_required

  scope :sorted, -> { order(created_at: :desc) }

  enum visibility_level: { draft: 0, active: 1 }

  translates :name, :title

  def self.alphabetically_sorted
    all.sort_by(&:title).reverse
  end

  def self.find_by_allowed_domain(domain)
    unless reserved_domains.include?(domain)
      find_by(domain: domain)
    end
  end

  def self.with_agendas_integration_enabled
    @with_agendas_integration_enabled ||= Site.all.select do |site|
      site.calendar_integration.present?
    end
  end

  def calendar_integration
    if gobierto_people_settings
      case gobierto_people_settings.calendar_integration
      when 'ibm_notes'
        GobiertoPeople::IbmNotes::CalendarIntegration
      when 'google_calendar'
        GobiertoPeople::GoogleCalendar::CalendarIntegration
      when 'microsoft_exchange'
        GobiertoPeople::MicrosoftExchange::CalendarIntegration
      end
    end
  end

  def gobierto_people_settings
    @gobierto_people_settings ||= if configuration.gobierto_people_enabled?
                                    module_settings.find_by(module_name: "GobiertoPeople")
                                  end
  end

  def gobierto_budgets_settings
    @gobierto_budgets_settings ||= if configuration.gobierto_budgets_enabled?
                                    module_settings.find_by(module_name: "GobiertoBudgets")
                                  end
  end

  def place
    @place ||= if self.municipality_id && self.location_name
                 INE::Places::Place.find self.municipality_id
               end
  end

  def configuration
    @configuration ||= SiteConfiguration.new(site_configuration_attributes)
  end

  def password_protected?
    draft?
  end

  def budgets_data_updated_at(index)
    activities.where('action ~* ?', "gobierto_budgets.budgets_#{index}_.*_updated")
              .order(created_at: :asc)
              .pluck(:created_at)
              .last
  end

  def to_s
    self.name
  end

  private

  def site_configuration_attributes
    {}.tap do |attributes|
      attributes.merge!(read_attribute(:configuration_data) || {})
      attributes.merge!('site_id' => self.id) unless new_record?
      attributes
    end
  end

  def self.reserved_domains
    @reserved_domains ||= RESERVED_SUBDOMAINS.map do |subdomain|
      "#{subdomain}." + ENV.fetch("HOST")
    end
  end
  private_class_method :reserved_domains

  def store_configuration
    self.configuration_data = self.configuration.instance_values
  end

  def initialize_admins
    self.admins = Array(GobiertoAdmin::Admin.preset)
  end

  def run_seeder
    if self.saved_change_to_attribute?('configuration_data') && added_modules_after_update.any?
      added_modules_after_update.each do |module_name|
        GobiertoCommon::GobiertoSeeder::ModuleSeeder.seed(module_name, self)
        GobiertoCommon::GobiertoSeeder::ModuleSiteSeeder.seed(APP_CONFIG['site']['name'], module_name, self)
      end
    end
  end

  def added_modules_after_update
    @added_modules_after_update ||= begin
      if self.configuration_data.has_key?('modules')
        configuration_data_before = self.attribute_before_last_save('configuration_data')
        if configuration_data_before && configuration_data_before.has_key?('modules')
          Array.wrap(self.configuration_data['modules']) - Array.wrap(configuration_data_before['modules'])
        else
          Array.wrap(self.configuration_data['modules'])
        end
      else
        []
      end
    end
  end

  def location_required
    if (self.configuration.modules & %W{ GobiertoBudgetConsultations GobiertoBudgets GobiertoIndicators} ).any?
      if municipality_id.blank? || location_name.blank?
        errors.add(:location_name, I18n.t('errors.messages.blank_for_modules'))
      end
    end
  end
end
