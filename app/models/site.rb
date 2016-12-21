class Site < ApplicationRecord

  RESERVED_SUBDOMAINS = %W(presupuestos hosted)

  # GobiertoAdmin integrations
  has_many :admin_sites, dependent: :destroy, class_name: "GobiertoAdmin::AdminSite"
  has_many :admins, through: :admin_sites, class_name: "GobiertoAdmin::Admin"
  has_many :census_imports, dependent: :destroy, class_name: "GobiertoAdmin::CensusImport"

  # User integrations
  has_many :subscriptions, dependent: :destroy, class_name: "User::Subscription"
  has_many :notifications, dependent: :destroy, class_name: "User::Notification"

  # GobiertoBudgetConsultations integration
  has_many :budget_consultations, dependent: :destroy, class_name: "GobiertoBudgetConsultations::Consultation"
  has_many :budget_consultation_responses, through: :budget_consultations, source: :consultation_responses, class_name: "GobiertoBudgetConsultations::ConsultationResponse"

  serialize :configuration_data

  before_save :store_configuration
  before_create :initialize_admins

  validates :title, presence: true
  validates :name, presence: true, uniqueness: true
  validates :location_name, presence: true
  validates :domain, presence: true, uniqueness: true, domain: true

  scope :sorted, -> { order(created_at: :desc) }
  scope :alphabetically_sorted, -> { order(name: :asc) }

  enum visibility_level: { draft: 0, active: 1 }

  def self.find_by_allowed_domain(domain)
    unless reserved_domains.include?(domain)
      find_by(domain: domain)
    end
  end

  def subdomain
    if domain.present? and domain.include?('.')
      domain.split('.').first
    end
  end

  def place
    @place ||= INE::Places::Place.find self.municipality_id
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
      "#{subdomain}." + Settings.gobierto_host
    end
  end
  private_class_method :reserved_domains

  def store_configuration
    self.configuration_data = self.configuration.instance_values
  end

  def initialize_admins
    self.admins = Array(GobiertoAdmin::Admin.preset)
  end
end
