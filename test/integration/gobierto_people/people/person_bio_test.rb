require "test_helper"
require_relative "base"

module GobiertoPeople
  module People
    class PersonBioTest < ActionDispatch::IntegrationTest
      include Base

      def setup
        super
        @path = gobierto_people_person_bio_path(person)
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

          assert has_selector?("h1", text: "#{person.name}'s profile")
          assert has_selector?("h2", text: "Biography and CV")
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

          assert_equal(
            person_bio_content_markup.strip,
            find(".dynamic-content").native.to_html.strip
          )
        end
      end

      private

      def person_bio_content_markup
        <<~HTML
          <div class="dynamic-content table-component">

              <h3>Contact methods</h3>
              <table class="explore_slow">
                <tr>
                    <th>Service</th>
                    <th>URL</th>
                    <th>Notes</th>
                </tr>
                <tbody>
                    <tr>
                        <td>Twitter</td>
                        <td>https://twitter.com/richard</td>
                        <td>Richard's Twitter account</td>
                    </tr>
                </tbody>
              </table>
              <h3>Accomplishments</h3>
              <table class="explore_slow">
                <tr>
                    <th>Title</th>
                    <th>Date</th>
                </tr>
                <tbody>
                    <tr>
                        <td>Nobel Prize in Chemistry</td>
                        <td>2016</td>
                    </tr>
                </tbody>
              </table>

          </div>
        HTML
      end
    end
  end
end
