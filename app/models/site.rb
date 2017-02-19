class Site < ApplicationRecord

  RESERVED_SUBDOMAINS = %W(presupuestos hosted)

  # GobiertoAdmin integrations
  has_many :admin_sites, dependent: :destroy, class_name: "GobiertoAdmin::AdminSite"
  has_many :admins, through: :admin_sites, class_name: "GobiertoAdmin::Admin"
  has_many :census_imports, dependent: :destroy, class_name: "GobiertoAdmin::CensusImport"

  # GobiertoCommon integration
  has_many :content_blocks, dependent: :destroy, class_name: "GobiertoCommon::ContentBlock"

  # User integrations
  has_many :subscriptions, dependent: :destroy, class_name: "User::Subscription"
  has_many :notifications, dependent: :destroy, class_name: "User::Notification"

  # GobiertoBudgetConsultations integration
  has_many :budget_consultations, dependent: :destroy, class_name: "GobiertoBudgetConsultations::Consultation"
  has_many :budget_consultation_responses, through: :budget_consultations, source: :consultation_responses, class_name: "GobiertoBudgetConsultations::ConsultationResponse"

  # GobiertoPeople integration
  has_many :people, dependent: :destroy, class_name: "GobiertoPeople::Person"
  has_many :person_events, through: :people, source: :events, class_name: "GobiertoPeople::PersonEvent"
  has_many :person_posts, through: :people, source: :posts, class_name: "GobiertoPeople::PersonPost"
  has_many :person_statements, through: :people, source: :statements, class_name: "GobiertoPeople::PersonStatement"
  has_many :gobierto_people_settings, class_name: "GobiertoPeople::Setting"

  serialize :configuration_data

  before_save :store_configuration
  before_create :initialize_admins
  after_save :run_seeder

  validates :title, presence: true
  validates :name, presence: true, uniqueness: true
  validates :domain, presence: true, uniqueness: true, domain: true
  validate :location_required

  scope :sorted, -> { order(created_at: :desc) }
  scope :alphabetically_sorted, -> { order(name: :asc) }

  enum visibility_level: { draft: 0, active: 1 }

  def self.find_by_allowed_domain(domain)
    unless reserved_domains.include?(domain)
      find_by(domain: domain)
    end
  end

  def place
    @place ||= if self.municipality_id && self.location_name
                 INE::Places::Place.find self.municipality_id
               end
  end

  def configuration
    @configuration ||= SiteConfiguration.new(read_attribute(:configuration_data))
  end

  def password_protected?
    draft?
  end

  private

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
    if self.configuration_data_changed? && added_modules_after_update.any?
      added_modules_after_update.each do |module_name|
        GobiertoCommon::GobiertoSeeder::ModuleSeeder.seed(module_name, self)
        GobiertoCommon::GobiertoSeeder::ModuleSiteSeeder.seed(APP_CONFIG['site']['name'], module_name, self)
      end
    end
  end

  def added_modules_after_update
    @added_modules_after_update ||= begin
      if self.configuration_data.has_key?('modules')
        if self.configuration_data_was && self.configuration_data_was.has_key?('modules')
          self.configuration_data['modules'] - self.configuration_data_was['modules']
        else
          self.configuration_data['modules']
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
