# frozen_string_literal: true

require "active_record/fixtures"

module GobiertoPeople
  class Factory
    def self.person(params = {})
      name = params[:name] || "Bob"

      GobiertoPeople::Person.create!(
        site: params[:site] || default_site,
        name: name,
        visibility_level: GobiertoPeople::Person.visibility_levels["active"],
        category: GobiertoPeople::Person.categories["politician"],
        party: GobiertoPeople::Person.parties["government"],
        position: rand(1..1_000),
        email: "#{name.downcase}@example.org"
      )
    end

    def self.trip(params = {})
      default_destinations = {
        "destinations" => [
          { "name" => "Amsterdam", "lat" => 52.3545653, "lon" => 4.7585402 }
        ]
      }

      GobiertoPeople::Trip.create!(
        person: params[:person] || default_person,
        start_date: params[:start_date] || 10.days.ago,
        end_date: params[:end_date] || 5.days.ago,
        title: params[:title] || "Trip title",
        department: params[:department] || default_department,
        destinations_meta: params[:destinations_meta] || default_destinations
      )
    end

    def self.invitation(params = {})
      GobiertoPeople::Invitation.create!(
        person: params[:person] || default_person,
        organizer: "Important Association",
        title: "Important Invitation",
        department: params[:department] || default_department,
        start_date: params[:start_date] || 1.month.ago,
        end_date: params[:end_date] || 1.month.ago + 1.day
      )
    end

    def self.gift(params = {})
      GobiertoPeople::Gift.create!(
        person: params[:person] || default_person,
        name: "Concert Ticket",
        department: params[:department] || default_department,
        date: params[:date] || 2.days.ago
      )
    end

    def self.department(params = {})
      name = params[:name] || "Department name"

      GobiertoPeople::Department.create!(
        site: params[:site] || default_site,
        name: name,
        slug: name.parameterize
      )
    end

    def self.default_site
      @default_site ||= Site.find(fixture(:madrid))
    end
    private_class_method :default_site

    def self.default_person
      @default_person ||= GobiertoPeople::Person.find(fixture(:richard))
    end
    private_class_method :default_person

    def self.default_department
      @default_department ||= GobiertoPeople::Department.find(fixture(:culture_department))
    end
    private_class_method :default_department

    def self.fixture(fixture_name)
      ActiveRecord::FixtureSet.identify(fixture_name)
    end
    private_class_method :fixture

  end
end
