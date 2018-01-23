# frozen_string_literal: true

module GobiertoIndicators
  class IndicatorsController < GobiertoIndicators::ApplicationController
    include User::SessionHelper

    before_action :load_year, only: [:ita, :ip]

    def index
      redirect_to gobierto_indicators_ita_path
    end

    def ip
    end

    def ita
      @ita_json = "/generated.json"
    end

    def gci
    end

    private

    def load_year
      if params[:year].nil?
        @indicator_json = current_site.indicators.where(name: params[:action]).first.indicator_response
        if params[:action] == "ita"
          redirect_to gobierto_indicators_ita_path(year: current_site.indicators.where(name: params[:action]).last.year.year)
        elsif params[:action] == "ip"
          redirect_to gobierto_indicators_ip_path(year: current_site.indicators.where(name: params[:action]).last.year.year)
        end
      else
        @year = params[:year].to_i
        @indicator_json = current_site.indicators.where("name LIKE ? AND extract(year from year) = ?", params[:action], @year).last.indicator_response
      end
    end
  end
end
