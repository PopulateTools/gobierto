class Site < ApplicationRecord

  RESERVED_SUBDOMAINS = %W(presupuestos)

  serialize :configuration_data

  before_save :store_configuration

  validates :title, presence: true
  validates :name, presence: true, uniqueness: true
  validates :location_name, presence: true
  validates :domain, presence: true, uniqueness: true, domain: true

  scope :sorted, -> { order(created_at: :desc) }

  enum visibility_level: { draft: 0, active: 1 }

  def self.reserved_domain?(domain)
    RESERVED_SUBDOMAINS.map do |subdomain|
      "#{subdomain}." + Settings.gobierto_host
    end.any?{ |reserved_domain| domain == reserved_domain }
  end

  def subdomain
    if domain.present? and domain.include?('.')
      domain.split('.').first
    end
  end

  def place
    @place ||= INE::Places::Place.find self.external_id
  end

  def configuration
    @configuration ||= SiteConfiguration.new(read_attribute(:configuration_data))
  end

  def password_protected?
    draft?
  end

  private

  def store_configuration
    self.configuration_data = self.configuration.instance_values
  end
end
