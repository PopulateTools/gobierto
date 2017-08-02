require 'test_helper'

module GobiertoParticipation
  class ProcessIndexTest < ActionDispatch::IntegrationTest

    def setup
      super
      @path = gobierto_participation_processes_path
    end

    def site
      @site ||= sites(:madrid)
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit @path

        within '.global_breadcrumb' do
          assert has_link? 'Participation'
          assert has_link? 'Processes'
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit @path

        within 'menu.sub_sections' do
          assert has_content? 'About'
          assert has_content? 'Issues'
          assert has_content? 'Processes'
          assert has_content? 'Ask'
          assert has_content? 'Ideas'
        end
      end
    end

    def test_secondary_nav
      with_current_site(site) do
        visit @path

        within 'menu.secondary_nav' do
          assert has_link? 'News'
          assert has_link? 'Agenda'
          assert has_link? 'Documents'
          assert has_link? 'Activity'
        end

        # TODO: check that these links redirect to their corresponding pages
        # applying the right scope (all processes/groups scope)
      end
    end

    def test_subscription_block
      with_current_site(site) do
        visit @path

        within '.site_header' do
          skip 'Not yet defined'
        end
      end
    end

  end
end
