# frozen_string_literal: true

module GobiertoPeople
  module BelongsToPersonWithCharge

    extend ActiveSupport::Concern

    class_methods do
      def belongs_to_person_with_historical_charge(opts = {})
        date_attribute = opts.fetch(:date_attribute, "date")

        if self == GobiertoCalendars::Event
          has_one :person, through: :collection, source: :container, source_type: "GobiertoPeople::Person", class_name: "GobiertoPeople::Person"
        else
          belongs_to :person, class_name: "GobiertoPeople::Person"
        end

        has_many :historical_charges, through: :person, class_name: "GobiertoPeople::Charge"
        has_one(
          :historical_charge,
          lambda { |item|
            where(
              "(gp_charges.start_date is null or gp_charges.start_date <= :date) and (gp_charges.end_date is null or gp_charges.end_date >= :date)",
              date: item.send(date_attribute)
            )
          },
          through: :person,
          class_name: "GobiertoPeople::Charge",
          source: :historical_charges
        )
        has_one :historical_department, through: :historical_charge, source: :department, class_name: "GobiertoPeople::Department"

        scope :with_charge, -> { joins(:historical_charges).where("gp_charges.start_date <= #{date_attribute} and gp_charges.end_date >= #{date_attribute}") }
      end
    end

    included do
      def person_name_with_charge
        return unless respond_to? :person

        "#{person&.name} - #{historical_charge&.name}"
      end
    end
  end
end
