# frozen_string_literal: true

require "test_helper"
require_relative "base"

module GobiertoPeople
  module People
    class PersonBioTest < ActionDispatch::IntegrationTest
      include Base

      def setup
        super
        @path = gobierto_people_person_bio_path(person.slug)
      end

      def site
        @site ||= sites(:madrid)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def test_person_bio
        with_current_site(site) do
          visit @path

          assert has_selector?("h2", text: "#{person.name}'s profile")
          assert has_selector?("h3", text: "Biography and CV")
        end
      end

      def test_person_bio_download_button
        with_current_site(site) do
          visit @path

          assert has_link?("Download CV")
        end
      end

      def test_person_bio_content
        with_current_site(site) do
          visit @path

          assert has_no_selector?("h3", text: "Contact methods")
          assert has_no_selector?("h3", text: "Associations")

          assert has_selector?("h3", text: "Accomplishments")

          assert has_content?("Nobel Prize in Chemistry")
          assert has_link?("nobel_prize.pdf")

          assert has_content?("Ran New York marathon")
          assert has_link?("marathon_certificate.pdf")
        end
      end
    end
  end
end
