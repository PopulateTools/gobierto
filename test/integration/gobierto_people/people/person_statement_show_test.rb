# frozen_string_literal: true

require "test_helper"
require_relative "base"

module GobiertoPeople
  module People
    class PersonStatementShowTest < ActionDispatch::IntegrationTest
      include Base

      def setup
        super
        @path = gobierto_people_person_statement_path(person.slug, statement.slug)
      end

      def site
        @site ||= sites(:madrid)
      end

      def person
        @person ||= gobierto_people_people(:richard)
      end

      def statement
        @statement ||= gobierto_people_person_statements(:richard_current)
      end

      def other_statements
        @other_statements ||= [
          gobierto_people_person_statements(:richard_past)
        ]
      end

      def test_person_statement_show
        with_current_site(site) do
          visit @path

          assert has_selector?("h2", text: "#{person.name}'s goods and Activities")
          assert has_selector?("h3", text: statement.title)
        end
      end

      def test_statement_download_button
        with_current_site(site) do
          visit @path

          assert has_link?("Download statement (100 KB)")
        end
      end

      def test_other_statements_block
        with_current_site(site) do
          visit @path

          within ".other-statements" do
            other_statements.each do |statement|
              assert has_link?(statement.title)
            end
          end
        end
      end

      def test_statement_content
        with_current_site(site) do
          visit @path

          assert has_content?("Declaración de Bienes y Actividades")
        end
      end

      def test_subscription_block
        skip "Subscription boxes are disabled"

        with_current_site(site) do
          visit @path

          within ".subscribable-box", match: :first do
            assert has_button?("Subscribe")
          end
        end
      end

      private

      def statement_content_markup
        <<~HTML
          <div class="dynamic-content table-component">

              <h3>Income</h3>
              <table class="explore_slow">
                <tr>
                    <th>Concept</th>
                    <th>Description</th>
                    <th>Amount</th>
                </tr>
                <tbody>
                    <tr>
                        <td>Dividends</td>
                        <td>Fixed amount per share</td>
                        <td>12.000</td>
                    </tr>
                </tbody>
              </table>
              <h3>Asset</h3>
              <table class="explore_slow">
                <tr>
                    <th>Class</th>
                    <th>Branch</th>
                    <th>Average balance</th>
                </tr>
                <tbody>
                    <tr>
                        <td>Regular account</td>
                        <td>Wadus</td>
                        <td>150.000</td>
                    </tr>
                </tbody>
              </table>

          </div>
        HTML
      end
    end
  end
end
