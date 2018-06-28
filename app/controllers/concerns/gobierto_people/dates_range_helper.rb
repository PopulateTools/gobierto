# frozen_string_literal: true

module GobiertoPeople
  module DatesRangeHelper
    extend ActiveSupport::Concern

    RANGE_PARAM_NAMES = %w(start_date end_date).freeze

    included do
      helper_method :dates_range?, :filter_start_date, :filter_end_date, :date_range_params
    end

    def date_range_params
      params.slice(:start_date, :end_date).permit(:start_date, :end_date)
    end

    def filter_start_date
      date_from_param(:start_date) if site_configuration_dates_range?
    end

    def filter_end_date
      date_from_param(:end_date) if site_configuration_dates_range?
    end

    def site_configuration_dates_range?
      site_configuration_date_range.values.compact.present?
    end

    def empty_date_range_param?
      (params.keys & RANGE_PARAM_NAMES).empty?
    end

    private

    def site_configuration_date_range
      @site_configuration_date_range ||= { start_date: parse_date(current_site.configuration.configuration_variables["gobierto_people_default_filter_start_date"]),
                                           end_date: parse_date(current_site.configuration.configuration_variables["gobierto_people_default_filter_end_date"]) }
    end

    def parse_date(date, fallback = nil)
      return unless date
      Time.zone.parse(date)
    rescue ArgumentError
      fallback
    end

    def inspect_query_params
      return unless site_configuration_dates_range?
      return if (reset_params = request.query_parameters.slice(*RANGE_PARAM_NAMES).select { |_, value| value == "false" }).blank?

      redirect_params = request.query_parameters.reject { |param, value| value == "false" && RANGE_PARAM_NAMES.include?(param) }
      redirect_query = redirect_params.present? ? "?#{ redirect_params.to_query }" : ""
      reset_params.each do |param, _|
        session[param] = nil
      end
      redirect_to(request.path + redirect_query) and return
    end

    def date_from_param(param)
      if params[param].present?
        parse_date(params[param], site_configuration_date_range[param])
      else
        site_configuration_date_range[param]
      end
    end

    def date_from_param_or_session(param)
      if params[param].present?
        session[param] = parse_date(params[param], site_configuration_date_range[param])
      else
        session[param] ||= site_configuration_date_range[param]
      end
    end
  end
end
