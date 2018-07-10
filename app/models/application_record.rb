class ApplicationRecord < ActiveRecord::Base
  include GobiertoCommon::AttributeLengthValidatable

  self.abstract_class = true

  protected

  def url_helpers
    Rails.application.routes.url_helpers
  end

end
