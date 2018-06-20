module GobiertoPeople
  class TripDecorator < BaseDecorator

    def initialize(person)
      @object = person
    end

    def company_members
      company.split(/\n|,/).map(&:strip).uniq
    end

    def formatted_start_date
      I18n.l(start_date, format: "%-d/%-m/%Y")
    end

    def formatted_end_date
      I18n.l(end_date, format: "%-d/%-m/%Y")
    end

  end
end
