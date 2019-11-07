# frozen_string_literal: true

require_dependency "gobierto_people"

module GobiertoPeople
  class Department < ApplicationRecord

    include GobiertoCommon::Metadatable
    include GobiertoCommon::UrlBuildable
    include GobiertoCommon::Sluggable

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

    def people
      self.class.filter_department_people(site.people, id).distinct
    end

    def short_name
      result = name.gsub(SHORT_NAME_TRUNCATE_REGEX, "")
      I18n.locale == :ca ? result.gsub("i d'", "i ") : result
    end

    def self.filter_department_people(people_relation, department_id)
      people_relation.left_outer_joins(attending_person_events: :event)
                     .where("gc_events.department_id = :id OR
gp_people.id IN (select distinct(person_id) FROM gp_trips WHERE gp_trips.department_id = :id) OR
gp_people.id IN (select distinct(person_id) FROM gp_invitations WHERE gp_invitations.department_id = :id) OR
gp_people.id IN (select distinct(person_id) FROM gp_gifts WHERE gp_gifts.department_id = :id)", id: department_id)
    end

  end
end
