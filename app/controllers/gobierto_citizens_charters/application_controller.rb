# frozen_string_literal: true

class GobiertoCitizensCharters::ApplicationController < ApplicationController
  include User::SessionHelper
  helper_method :services_enabled?, :services_home_enabled?

  layout "gobierto_citizens_charters/layouts/application"

  before_action { module_enabled!(current_site, "GobiertoCitizensCharters") }

  def services_enabled?
    !current_site.gobierto_citizens_charters_settings&.disable_services
  end

  def services_home_enabled?
    services_enabled? && current_site.gobierto_citizens_charters_settings&.enable_services_home
  end

  private

  def period_params
    @period_params ||= begin
                         case params[:front_period_interval]
                         when "a"
                           return { period_interval: "year", period: DateTime.new(params[:period].to_i) }
                         when "c"
                           year, month = params[:period].split("-")
                           month = 1 + ((month.to_i - 1) % 3) * 3
                           return { period_interval: "quarter", period: DateTime.new(year.to_i, month) }
                         when "m"
                           year, month = params[:period].split("-")
                           return { period_interval: "month", period: DateTime.new(year.to_i, month.to_i) }
                         when "s"
                           year, week = params[:period].split("-")
                           return { period_interval: "week", period: DateTime.commercial(year.to_i, week.to_i, 1) }
                         end
                       end
  end
end
