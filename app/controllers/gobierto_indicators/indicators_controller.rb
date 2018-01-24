# frozen_string_literal: true

module GobiertoIndicators
  class IndicatorsController < GobiertoIndicators::ApplicationController
    include User::SessionHelper

    before_action :load_indicators, only: [:ita, :ip]
    before_action :load_year, only: [:ita, :ip]
    before_action :load_indicator_json, only: [:ita, :ip]

    def index
      redirect_to gobierto_indicators_indicators_ita_path
    end

    def ip
    end

    def ita
    end

    def gci
    end

    private

    def load_indicators
      @indicators = current_site.indicators.where(name: params[:action])
    end

    def load_year
      if params[:year].nil?
        if params[:action] == "ita"
          redirect_to gobierto_indicators_indicators_ita_path(year: @indicators.last.year)
        elsif params[:action] == "ip"
          redirect_to gobierto_indicators_indicators_ip_path(year: @indicators.last.year)
        end
      else
        @year = params[:year].to_i
      end
    end

    def load_indicator_json
      @indicator_json = current_site.indicators.where("name = ? AND year = ?", params[:action], @year).last.indicator_response
    end
  end
end
