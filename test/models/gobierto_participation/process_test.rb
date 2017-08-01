require 'test_helper'

module GobiertoCms
  class ProcessTest < ActiveSupport::TestCase

    def process
      @process ||= gobierto_participation_processes(:gender_violence_process)
    end
    alias collectionable_object process

    def process_news
      [ gobierto_cms_pages(:notice_1), gobierto_cms_pages(:notice_2) ]
    end

    def process_events
      [ gobierto_people_person_events(:richard_published), gobierto_people_person_events(:nelson_tomorrow) ]
    end

    def test_valid
      assert process.valid?
    end

    def test_process_news
      assert array_match process_news, process.news
    end

    def test_process_events
      assert array_match process_events, process.events
    end

  end
end
