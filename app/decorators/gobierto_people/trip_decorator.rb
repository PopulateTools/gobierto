module GobiertoPeople
  class TripDecorator < BaseDecorator

    CASE_CHANGE_REGEXP = /(?<=[a-z])(?=[A-Z])/
    SPLIT_COMPANY_REGEXP = /\n|\s\s|#{CASE_CHANGE_REGEXP}/

    def initialize(trip)
      @object = trip
    end

    def company_members
      company ? company.split(SPLIT_COMPANY_REGEXP).map(&:strip).uniq : []
    end

    def formatted_start_date
      I18n.l(start_date, format: "%-d/%-m/%Y")
    end

    def formatted_end_date
      I18n.l(end_date, format: "%-d/%-m/%Y")
    end

  end
end
