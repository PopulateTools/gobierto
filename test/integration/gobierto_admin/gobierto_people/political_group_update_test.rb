# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  module GobiertoPeople
    class PoliticalGroupUpdateTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = edit_admin_people_configuration_political_group_path(political_group)
      end

      def political_group
        @political_group ||= gobierto_people_political_groups(:marvel)
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_political_group_update
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within 'form.edit_political_group' do
              fill_in 'political_group_name', with: 'Political group name'

              click_button 'Update'
            end

            assert has_message?('Political group was successfully update')

            within 'form.edit_political_group' do
              assert has_field?('political_group_name', with: 'Political group name')
            end
          end
        end
      end
    end
  end
end
