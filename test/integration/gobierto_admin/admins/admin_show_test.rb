# frozen_string_literal: true

require "test_helper"

module GobiertoAdmin
  class AdminShowTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = admin_admin_path(admin)
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def test_admin_show
      with_signed_in_admin(admin) do
        visit @path

        within ".admin_content" do
          assert has_content?(admin.name)
          assert has_link?(admin.email)
        end
      end
    end
  end
end
