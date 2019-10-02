# frozen_string_literal: true

module GobiertoIndicators
  class IndicatorsController < GobiertoIndicators::ApplicationController
    include User::SessionHelper

    before_action :overrided_root_redirect, only: [:index]
    before_action :load_indicators, only: [:ita, :ip, :gci]
    before_action :load_years, only: [:ita, :ip, :gci]
    before_action :load_year, only: [:ita, :ip, :gci]

    def index
      redirect_to gobierto_indicators_indicators_ita_path
    end

    def ip
      load_boolean_indicator

      indicator_update_datetime

      respond_to do |format|
        format.html
        format.json do
          render(
            json: { indicator: @indicator }
          )
        end
      end
    end

    def ita
      load_boolean_indicator

      indicator_update_datetime

      respond_to do |format|
        format.html
        format.json do
          render(
            json: { indicator: @indicator }
          )
        end
      end
    end

    def gci
      @indicator = JSON.parse(load_indicators.last.indicator_response)

      @indicator.each do |letter|
        letter["children"].each do |section|
          section["children"].delete_if { |indicator| indicator["attributes"]["values"].none? { |h| h.keys[0] == params[:year] } }
        end
        letter["children"].delete_if { |section| section["children"] == [] }
      end

      @indicator.delete_if { |letter| letter["children"] == [] }

      indicator_update_datetime

      respond_to do |format|
        format.html
        format.json do
          render(
            json: { indicator: @indicator.to_json }
          )
        end
      end
    end

    private

    def indicator_update_datetime
      indicator = if params[:action] == "gci"
                    current_site.indicators.find_by(name: params[:action])
                  else
                    current_site.indicators.find_by(name: params[:action], year: params[:year])
                  end

      @site_stats = GobiertoIndicators::SiteStats.new site: current_site, indicator: indicator
      @indicator_updated_at = @site_stats.indicator_updated_at
    end

    def load_indicators
      @indicators = current_site.indicators.where(name: params[:action])
    end

    def load_years
      @years = []

      if params[:action] == "gci"
        indicator_json = JSON.parse(load_indicators.last.indicator_response)

        indicator_json.each do |letter|
          letter["children"].each do |section|
            section["children"].each do |indicator|
              indicator["attributes"]["values"].each do |value|
                value.each do |h|
                  year = h.first
                  unless @years.include?(year)
                    @years.push(year)
                  end
                end
              end
            end
          end
        end
      else
        @years = @indicators.pluck(:year).map(&:to_s)
      end
      @years = @years.sort { |x, y| x <=> y }.reverse!
    end

    def load_year
      if params[:year].nil?
        if params[:action] == "ita"
          redirect_to gobierto_indicators_indicators_ita_path(year: @indicators.last.year)
        elsif params[:action] == "ip"
          redirect_to gobierto_indicators_indicators_ip_path(year: @indicators.last.year)
        elsif params[:action] == "gci"
          redirect_to gobierto_indicators_indicators_gci_path(year: @years.first)
        end
      else
        @year = params[:year].to_i
      end
    end

    def load_boolean_indicator
      @indicator = current_site.indicators.where("name = ? AND year = ?", params[:action], @year).last.indicator_response
    end
  end
end
