# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCitizensCharters
    module Editions
      class EditionssIndexTest < ActionDispatch::IntegrationTest
        def setup
          super
          @path = admin_citizens_charters_charter_editions_path(charter, period: "2018-01-01", period_interval: :year)
        end

        def admin
          @admin ||= gobierto_admin_admins(:nick)
        end

        def unauthorized_admin
          @unauthorized_admin ||= gobierto_admin_admins(:steve)
        end

        def site
          @site ||= sites(:madrid)
        end

        def charter
          @charter ||= gobierto_citizens_charters_charters(:day_care_service_charter)
        end

        def commitments
          @commitments ||= charter.commitments
        end

        def test_permissions
          with_signed_in_admin(unauthorized_admin) do
            with_current_site(site) do
              visit @path
              assert has_content?("You are not authorized to perform this action")
              assert_equal edit_admin_admin_settings_path, current_path
            end
          end
        end

        def test_order_by_commitments_title
          with(admin: admin, site: site, js: true) do
            visit(@path)
            within "div.jsgrid-grid-body table.jsgrid-table" do
              commitments_titles = find_all("tr").map { |row| row.find_all("td")[0].text }
              assert_equal commitments_titles, commitments_titles.sort
            end
          end
        end
      end
    end
  end
end
