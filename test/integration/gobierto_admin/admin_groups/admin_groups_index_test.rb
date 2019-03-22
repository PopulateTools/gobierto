# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class AdminGroupsIndexTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = admin_admin_groups_path
    end

    def madrid
      @madrid ||= sites(:madrid)
    end

    def regular_admin
      @regular_admin ||= gobierto_admin_admins(:tony)
    end

    def manager_admin
      @manager_admin ||= gobierto_admin_admins(:nick)
    end

    def madrid_group
      @madrid_group ||= gobierto_admin_admin_groups(:madrid_group)
    end

    def other_site_group
      @other_site_group ||= gobierto_admin_admin_groups(:santander_group)
    end

    def test_index
      with_current_site(madrid) do
        with_signed_in_admin(manager_admin) do
          visit @path

          within "table.admin-list tbody" do
            assert has_selector?("tr#admin-item-#{madrid_group.id}")
            assert has_no_selector?("tr#admin-item-#{other_site_group.id}")
          end
        end
      end
    end

    def test_regular_admin_index
      with_current_site(madrid) do
        with_signed_in_admin(regular_admin) do
          visit @path
          assert has_no_selector?("tr#admin-item-#{madrid_group.id}")
        end
      end
    end
  end
end
