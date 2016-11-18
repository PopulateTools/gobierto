module Integration
  module SiteSessionHelpers
    def with_selected_site(site)
      select_site(site)
      yield
    end

    private

    def select_site(site)
      visit admin_root_path

      within("#managed-sites-list") do
        click_button site.name
      end
    end
  end
end
