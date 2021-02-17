# frozen_string_literal: true

module GobiertoPeople
  class Department < ApplicationRecord

    include GobiertoCommon::Metadatable
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Sluggable
    include ActiveRecord::Sanitization::ClassMethods

    belongs_to :site
    has_many :charges
    has_many :people_with_charge, through: :charges, source: :person
    has_many(
      :events,
      lambda {
        where(
          %{
            (#{Charge.table_name}.start_date is NULL OR #{Charge.table_name}.start_date <= #{GobiertoCalendars::Event.table_name}.starts_at)
            AND
            (#{Charge.table_name}.end_date is null or #{Charge.table_name}.end_date >= #{GobiertoCalendars::Event.table_name}.starts_at)
          }
        )
      },
      through: :people_with_charge,
      source: :attending_events
    )
    has_many(
      :gifts,
      lambda {
        where(
          %{
            (#{Charge.table_name}.start_date is NULL OR #{Charge.table_name}.start_date <= #{Gift.table_name}.date)
            AND
            (#{Charge.table_name}.end_date is null or #{Charge.table_name}.end_date >= #{Gift.table_name}.date)
          }
        )
      },
      through: :people_with_charge,
      source: :received_gifts
    )
    has_many(
      :trips,
      lambda {
        where(
          %{
            (#{Charge.table_name}.start_date is NULL OR #{Charge.table_name}.start_date <= #{Trip.table_name}.start_date)
            AND
            (#{Charge.table_name}.end_date is null or #{Charge.table_name}.end_date >= #{Trip.table_name}.start_date)
          }
        )
      },
      through: :people_with_charge,
      source: :trips
    )
    has_many(
      :invitations,
      lambda {
        where(
          %{
            (#{Charge.table_name}.start_date is NULL OR #{Charge.table_name}.start_date <= #{Invitation.table_name}.start_date)
            AND
            (#{Charge.table_name}.end_date is null or #{Charge.table_name}.end_date >= #{Invitation.table_name}.start_date)
          }
        )
      },
      through: :people_with_charge,
      source: :invitations
    )

    has_many :gift_receivers

    scope :sorted, -> { order(name: :asc) }

    validates :name, presence: true
    validates :slug, uniqueness: { scope: :site_id }

    SHORT_NAME_TRUNCATE_REGEX = Regexp.new([
      "Departamento de ",
      "Departamento ",
      "Department of ",
      "Departament de la ",
      "Departament de ",
      "Departament d'"
    ].join("|")).freeze

    def to_param
      slug
    end

    def parameterize
      { id: slug }
    end

    def attributes_for_slug
      [name]
    end

    def people(params = {})
      people_with_charge.where(Charge.date_range_sql(params), params).distinct
    end

    def short_name
      result = name.gsub(SHORT_NAME_TRUNCATE_REGEX, "")
      I18n.locale == :ca ? result.gsub("i d'", "i ") : result
    end

    def self.filter_department_people(params = {})
      people_relation = params.delete(:people_relation)

      people_relation.joins(:historical_charges).where(Charge.date_range_sql(params), params).where("#{Charge.table_name}.department_id = :department_id", params).distinct
    end
  end
end
