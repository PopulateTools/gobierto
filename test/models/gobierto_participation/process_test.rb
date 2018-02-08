# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessTest < ActiveSupport::TestCase

    def green_city_group
      @green_city_group ||= gobierto_participation_processes(:green_city_group_active_empty)
    end
    alias group_without_stages green_city_group

    def local_budgets_process
      @local_budgets_process ||= gobierto_participation_processes(:local_budgets_process)
    end
    alias process_with_one_open_stage local_budgets_process

    def gender_violence_process
      @gender_violence_process ||= gobierto_participation_processes(:gender_violence_process)
    end
    alias process gender_violence_process
    alias collectionable_object gender_violence_process
    alias process_with_several_open_stages gender_violence_process

    def commission_for_carnival_festivities
      @commission_for_carnival_festivities ||= gobierto_participation_processes(:commission_for_carnival_festivities)
    end
    alias process_with_only_current_stage commission_for_carnival_festivities

    def site
      @site ||= sites(:madrid)
    end

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
      assert array_match process_news, process.news
    end

    def test_process_events
      assert array_match process_events, process.events
    end

    def test_current_stage
      assert_nil group_without_stages.current_stage
      assert_equal "sugiere-idea", process_with_one_open_stage.current_stage.slug
      assert_equal "dialogo", process_with_several_open_stages.current_stage.slug # within active and open stages, the one which finishes the latest
      assert_equal "encuestas", process_with_only_current_stage.current_stage.slug
    end

    def test_next_stage
      assert_nil group_without_stages.next_stage
      assert_nil process_with_one_open_stage.next_stage
      assert_equal "presentacion", process_with_several_open_stages.next_stage.slug
      assert_nil process_with_only_current_stage.next_stage
    end

    def test_create_process_creates_collections
      process = site.processes.create! title: "Foo"

      assert process.news_collection.present?
      assert process.events_collection.present?
      assert process.attachments_collection.present?
    end

    def test_destroy
      green_city_group.destroy

      assert green_city_group.slug.include?("archived-")
    end
  end
end
