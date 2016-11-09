module SiteSessionHelpers
  def with_current_site(site)
    GobiertoSiteConstraint.stub_any_instance(:matches?, true) do
      ApplicationController.stub_any_instance(:current_site, site) do
        yield
      end
    end
  end
end
