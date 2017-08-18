# frozen_string_literal: true

require "test_helper"

module GobiertoCms
  class ProcessTest < ActiveSupport::TestCase
    def process
      @process ||= gobierto_participation_processes(:gender_violence_process)
    end
    alias collectionable_object process

    def process_news
      [gobierto_cms_pages(:notice_1), gobierto_cms_pages(:notice_2)]
    end

    def process_events
      [gobierto_calendars_events(:reading_club), gobierto_calendars_events(:swimming_lessons)]
    end

    def test_valid
      assert process.valid?
    end

    def test_process_news
      assert array_match process_news, process.news_in_collections
    end

    def test_process_events
      assert array_match process_events, process.events_in_collections
    end
  end
end
