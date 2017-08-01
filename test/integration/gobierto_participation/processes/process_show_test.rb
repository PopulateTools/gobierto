require 'test_helper'

module GobiertoParticipation
  class ProcessShowTest < ActionDispatch::IntegrationTest

    def setup
      super
      @path = gobierto_participation_process_path(process.slug)
    end

    def site
      @site ||= sites(:madrid)
    end

    def process
      @process ||= gobierto_participation_processes(:gender_violence_process)
    end

    def test_breadcrumb_items
      with_current_site(site) do
        visit @path

        within '.global_breadcrumb' do
          assert has_link? 'Participation'
          assert has_link? 'Processes'
          assert has_link? process.title
        end
      end
    end

    def test_menu_subsections
      with_current_site(site) do
        visit @path

        within 'menu.sub_sections' do
          assert has_content? 'Information'
          assert has_content? 'Meetings'
          assert has_content? 'Polls'
          assert has_content? 'Contributions'
          assert has_content? 'Results'
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
        # applying the right scope (single process/group scope)
      end
    end

    def test_subscription_block
      with_current_site(site) do
        visit @path

        within '.site_header' do
          assert has_content? 'Follow this process'
        end
      end
    end

    def test_process
      with_current_site(site) do
        visit @path

        within '.container' do
          assert has_content? process.title
          assert has_content? process.body

          assert has_content? 'Interesting information'

          process_duration_text = "#{process.starts.strftime('%d/%m/%y')} to #{process.ends.strftime('%d/%m/%y')}"

          assert has_content? process_duration_text
          assert has_content? 'Women'
          # TODO: assert has_content? 'Strategic' (~Ámbito)
        end
      end
    end

    def test_process_news
      with_current_site(site) do
        visit @path

        assert_equal process.news.size, all('.place_news-item').size

        news_titles = process.news.map { |notice| notice.title }

        assert array_match ['Notice 1 title', 'Notice 2 title'], news_titles
      end
    end

    def test_process_events
      with_current_site(site) do
        visit @path

        assert_equal process.events.size, all('.place_event-item').size

        events_titles = process.events.map { |event| event.title }

        assert array_match ['Future government event', 'Nelson tomorrow event'], events_titles
      end
    end

    def test_process_activities
      with_current_site(site) do
        visit @path

        skip 'Not yet defined'
      end
    end

    def test_process_stages
      with_current_site(site) do
        visit @path

        within '.timeline' do
          assert_equal process.stages.size, all('.timeline_row').size
        end
      end
    end

  end
end
