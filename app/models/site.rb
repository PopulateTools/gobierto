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

  # User integrations
  has_many :subscriptions, dependent: :destroy, class_name: "User::Subscription"
  has_many :notifications, dependent: :destroy, class_name: "User::Notification"
  has_many :users, dependent: :nullify

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

  # Gobierto Core integration
  has_many :site_templates, dependent: :destroy, class_name: "GobiertoCore::SiteTemplate"

  # Gobierto Plans integration
  has_many :plans, dependent: :destroy, class_name: "GobiertoPlans::Plan"
  has_many :plan_types, dependent: :destroy, class_name: "GobiertoPlans::PlanType"

  # Gobierto Indicators
  has_many :indicators, dependent: :destroy, class_name: "GobiertoIndicators::Indicator"

  # Gobierto Attachments integration
  has_many :attachments, dependent: :destroy, class_name: "GobiertoAttachments::Attachment"

  # Modules settings
  has_many :module_settings, dependent: :destroy, class_name: "GobiertoModuleSettings"

  # Gobierto Participation integration
  has_many :issues, -> { sorted }, dependent: :destroy, class_name: "Issue"
  has_many :scopes, -> { sorted }, dependent: :destroy, class_name: "GobiertoCommon::Scope"
  has_many :processes, dependent: :destroy, class_name: "GobiertoParticipation::Process"
  has_many :contribution_containers, dependent: :destroy, class_name: "GobiertoParticipation::ContributionContainer"
  has_many :contributions, dependent: :destroy, class_name: "GobiertoParticipation::Contribution"
  has_many :comments, dependent: :destroy, class_name: "GobiertoParticipation::Comment"
  has_many :flags, dependent: :destroy, class_name: "GobiertoParticipation::Flag"
  has_many :votes, dependent: :destroy, class_name: "GobiertoParticipation::Vote"

  serialize :configuration_data

  before_save :store_configuration
  before_create :initialize_admins
  after_save :run_seeder

  validates :title, presence: true
  validates :domain, presence: true, uniqueness: true, domain: true
  validate :organization_required

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

  # If the organization_id corresponds to a municipality ID,
  # this method will return an instance of INE::Places::Place
  def place
    @place ||= if self.organization_id
                 INE::Places::Place.find(self.organization_id)
               end
  end

  def configuration
    @configuration ||= SiteConfiguration.new(site_configuration_attributes)
  end

  def password_protected?
    draft?
  end

  def to_s
    self.name
  end

  def engines_overrides
    configuration.engine_overrides
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

  def organization_required
    if (self.configuration.modules & %W{ GobiertoBudgetConsultations GobiertoBudgets GobiertoObservatory }).any?
      if organization_id.blank?
        errors[:base] << I18n.t('errors.messages.blank_for_modules')
      end
    end
  end
end
