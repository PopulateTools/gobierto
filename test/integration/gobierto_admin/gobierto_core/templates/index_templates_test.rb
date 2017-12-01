# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  module GobiertoCore
    class IndexTemplatesTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = admin_gobierto_core_templates_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def template
        @template ||= gobierto_core_templates(:participation_index)
      end

      def test_index
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within ".file_browser" do
              assert has_link? template.template_path.split("/").last
            end
          end
        end
      end
    end
  end
end
