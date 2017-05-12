module User::Subscribable
  extend ActiveSupport::Concern

  included do
    def self.subscribable_label
      model_name.human.pluralize(I18n.locale)
    end
  end

  def subscribable_label
    try(:title) || try(:name)
  end

  def to_path
    url_helpers.send("#{singular_route_key}_path", parameterize)
  end
  alias_method :resource_path, :to_path

  def to_url(options = {})
    url_helpers.send(
      "#{singular_route_key}_url",
      parameterize.merge(host: app_host).merge(options)
    )
  end

  private

  def parameterize
    { id: id }
  end

  def singular_route_key
    self.model_name.singular_route_key
  end

  def app_host
    @app_host ||= ENV.fetch("HOST") { "gobierto.dev" }
  end

  protected

  def url_helpers
    Rails.application.routes.url_helpers
  end
end
