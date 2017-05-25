# frozen_string_literal: true

require 'test_helper'

module GobiertoAdmin
  module GobiertoPeople
    class PoliticalGroupCreateTest < ActionDispatch::IntegrationTest
      def setup
        super
        @path = new_admin_people_configuration_political_group_path
      end

      def admin
        @admin ||= gobierto_admin_admins(:nick)
      end

      def site
        @site ||= sites(:madrid)
      end

      def test_political_group_create
        with_signed_in_admin(admin) do
          with_current_site(site) do
            visit @path

            within 'form.new_political_group' do
              fill_in 'political_group_name', with: 'Political group name'

              click_button 'Create'
            end

            assert has_message?('Political group was successfully created')

            within 'form.edit_political_group' do
              assert has_field?('political_group_name', with: 'Political group name')
            end
          end
        end
      end
    end
  end
end
