# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class PeopleSubmodulesTest < ActionDispatch::IntegrationTest
    def setup
      super
      @path = gobierto_people_people_path
    end

    def site
      @site ||= sites(:madrid)
    end

    def richard
      gobierto_people_people(:richard)
    end

    def disable_submodule(submodule_name)
      submodules_enabled = site.gobierto_people_settings.submodules_enabled
      submodules_enabled.delete(submodule_name)
      site.gobierto_people_settings.submodules_enabled = submodules_enabled
      site.gobierto_people_settings.save!
    end

    def disable_submodules(submodules_names)
      submodules_names.each { |submodule_name| disable_submodule(submodule_name) }
    end

    def test_main_menu_subsections
      with_current_site(site) do
        visit @path

        within ".sub-nav" do
          assert has_content? "Agendas"
          assert has_content? "Officials"
          assert has_content? "Statements"
          assert has_content? "Blogs"
        end

        disable_submodule("blogs")

        visit @path

        within ".sub-nav" do
          assert has_content? "Agendas"
          assert has_content? "Officials"
          assert has_content? "Statements"
          refute has_content? "Blogs"
        end

        disable_submodule("officials")
        disable_submodule("statements")

        visit @path

        within ".sub-nav" do
          assert has_content? "Agendas"
          refute has_content? "Officials"
          refute has_content? "Statements"
          refute has_content? "Blogs"
        end
      end
    end

    def test_welcome_page_redirections
      with_current_site(site) do
        visit @path

        assert_equal current_path, gobierto_people_people_path

        disable_submodules %w(blogs statements)
        visit @path

        assert_equal current_path, gobierto_people_people_path

        disable_submodule "officials"
        visit @path

        assert_equal current_path, gobierto_people_events_path
      end
    end

    def test_submodule_page_hides_disabled_submodules_components
      with_current_site(site) do
        visit gobierto_people_person_path(richard.slug)

        within ".people-navigation" do
          assert has_link? "Agenda"
          assert has_link? "Goods and Activities"
        end

        assert has_selector? "div .upcoming-events"

        disable_submodules %w(agendas statements)

        visit gobierto_people_person_path(richard.slug)

        within ".people-navigation" do
          refute has_link? "Agenda"
          refute has_link? "Goods and Activities"
        end

        refute has_selector? "div .upcoming-events"
      end
    end
  end
end
