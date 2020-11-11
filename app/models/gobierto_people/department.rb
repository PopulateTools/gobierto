# frozen_string_literal: true

module GobiertoPeople
  class Department < ApplicationRecord

    include GobiertoCommon::Metadatable
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Sluggable
    include ActiveRecord::Sanitization::ClassMethods

    belongs_to :site
    has_many :events, class_name: "GobiertoCalendars::Event"
    has_many :gifts
    has_many :invitations
    has_many :trips

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
      self.class.filter_department_people(
        params.slice(:from_date, :to_date)
              .merge(people_relation: site.people, department_id: id)
      ).distinct
    end

    def short_name
      result = name.gsub(SHORT_NAME_TRUNCATE_REGEX, "")
      I18n.locale == :ca ? result.gsub("i d'", "i ") : result
    end

    def self.filter_department_people(params = {})
      params[:people_relation].left_outer_joins(attending_person_events: :event)
                              .where(%{
        #{department_people_linked_throught_events_sql(params)} OR
        gp_people.id IN (#{department_people_linked_through_trips_sql(params)}) OR
        gp_people.id IN (#{department_people_linked_through_invitations_sql(params)}) OR
        gp_people.id IN (#{department_people_linked_through_gifts_sql(params)})
      })
    end

    ## private

    def self.department_people_linked_throught_events_sql(params = {})
      sql = sanitize_sql(["(gc_events.department_id = ?", params[:department_id]])
      sql += sanitize_sql([" AND gc_events.starts_at >= ?", params[:from_date]]) if params[:from_date]
      sql += sanitize_sql([" AND gc_events.ends_at < ?", params[:to_date]]) if params[:to_date]
      "#{sql})"
    end

    def self.department_people_linked_through_trips_sql(params = {})
      people = GobiertoPeople::Trip.select("DISTINCT(person_id)")
                                   .where(department_id: params[:department_id])
                                   .reorder("")
      people = people.where("start_date >= ?", params[:from_date]) if params[:from_date]
      people = people.where("end_date < ?", params[:to_date]) if params[:to_date]
      people.to_sql
    end
    private_class_method :department_people_linked_through_trips_sql

    def self.department_people_linked_through_invitations_sql(params = {})
      people = GobiertoPeople::Invitation.select("DISTINCT(person_id)")
                                         .where(department_id: params[:department_id])
                                         .reorder("")
      people = people.where("start_date >= ?", params[:from_date]) if params[:from_date]
      people = people.where("end_date < ?", params[:to_date]) if params[:to_date]
      people.to_sql
    end
    private_class_method :department_people_linked_through_invitations_sql

    def self.department_people_linked_through_gifts_sql(params = {})
      people = GobiertoPeople::Gift.select("DISTINCT(person_id)")
                                   .where(department_id: params[:department_id])
                                   .reorder("")
      people = people.where("date >= ?", params[:from_date]) if params[:from_date]
      people = people.where("date < ?", params[:to_date]) if params[:to_date]
      people.to_sql
    end
    private_class_method :department_people_linked_through_gifts_sql
  end
end
