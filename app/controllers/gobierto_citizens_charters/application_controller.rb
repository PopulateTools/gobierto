# frozen_string_literal: true

class GobiertoCitizensCharters::ApplicationController < ApplicationController
  include User::SessionHelper

  layout "gobierto_citizens_charters/layouts/application"

  before_action { module_enabled!(current_site, "GobiertoCitizensCharters") }

  private

  def period_params
    @period_params ||= begin
                         case params[:period_interval]
                         when "year"
                           return { period_interval: "year", period: Date.new(params[:period].to_i) }
                         when "quarter"
                           year, month = params[:period].split("-")
                           month = 1 + ((month.to_i - 1) % 3) * 3
                           return { period_interval: "quarter", period: Date.new(year.to_i, month) }
                         when "month"
                           year, month = params[:period].split("-")
                           return { period_interval: "quarter", period: Date.new(year.to_i, month) }
                         when "week"
                           year, week = params[:period].split("-")
                           return { period_interval: "quarter", period: Date.commercial(year.to_i, week.to_i, 1) }
                         end
                       end
  end
end
