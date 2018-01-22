# frozen_string_literal: true

module SiteSessionHelpers
  def with_current_site(site)
    raise(Exception, 'GobiertoSiteConstraint.matches? already stubbed. Maybe with_current_site is in use outside this block?') if GobiertoSiteConstraint.new.public_methods.include?(:__minitest_any_instance_stub__matches?)
    GobiertoSiteConstraint.stub_any_instance(:matches?, true) do
      ApplicationController.stub_any_instance(:current_site, site) do
        GobiertoAdmin::BaseController.stub_any_instance(:current_site, SiteDecorator.new(site)) do
          yield
        end
      end
    end
  end

  def with_current_site_with_host(site)
    with_current_site(site) do
      with_site_host(site) do
        yield
      end
    end
  end
end
