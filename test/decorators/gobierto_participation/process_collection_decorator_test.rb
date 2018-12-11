# frozen_string_literal: true

require "test_helper"

module GobiertoParticipation
  class ProcessCollectionDecoratorTest < ActiveSupport::TestCase

    def site
      sites(:madrid)
    end

    def participation_process
      @participation_process = gobierto_participation_processes :gender_violence_process
    end

    def participation_group
      @participation_group = gobierto_participation_processes :bowling_group_very_active
    end

    def issue
      @issue ||= gobierto_common_terms(:women_term)
    end

    def scope
      @scope ||= gobierto_common_terms(:old_town_term)
    end

    def participation_events
      site.events.joins(:collection).where(collections: { container_type: ["GobiertoParticipation", "GobiertoParticipation::Process"] })
    end

    def participation_pages
      site.pages.joins(:collection).where(collections: { container_type: ["GobiertoParticipation", "GobiertoParticipation::Process"] })
    end

    def participation_news
      site.pages.joins(:collection).where(collections: { container_type: ["GobiertoParticipation", "GobiertoParticipation::Process"], item_type: "GobiertoCms::News" })
    end

    def participation_attachments
      site.attachments.joins(:collection).where(collections: { container_type: ["GobiertoParticipation", "GobiertoParticipation::Process"] })
    end

    def events_decorator
      ProcessCollectionDecorator.new(site.events)
    end

    def attachments_decorator
      ProcessCollectionDecorator.new(site.attachments)
    end

    def news_decorator
      ProcessCollectionDecorator.new(site.pages, item_type: "GobiertoCms::News")
    end

    def test_events_in_participation_module
      participation_events.each do |event|
        assert_includes events_decorator.in_participation_module, event
      end
    end

    def test_resources_of_deleted_process
      participation_process.destroy

      participation_events.where(collections: { container: participation_process }).each do |resource|
        refute_includes events_decorator.in_participation_module, resource
        assert_includes events_decorator.in_participation_module(with_archived: true), resource
      end

      participation_attachments.where(collections: { container: participation_process }).each do |resource|
        refute_includes attachments_decorator.in_participation_module, resource
        assert_includes attachments_decorator.in_participation_module(with_archived: true), resource
      end

      participation_news.where(collections: { container: participation_process }).each do |resource|
        refute_includes news_decorator.in_participation_module, resource
        assert_includes news_decorator.in_participation_module(with_archived: true), resource
      end
    end

    def test_resource_of_deleted_process_without_callbacks
      participation_process.update_column(:archived_at, 1.hour.ago)

      participation_events.where(collections: { container: participation_process }).each do |resource|
        refute_includes events_decorator.in_participation_module, resource
        assert_includes events_decorator.in_participation_module(with_archived: true), resource
      end

      participation_attachments.where(collections: { container: participation_process }).each do |resource|
        refute_includes attachments_decorator.in_participation_module, resource
        assert_includes attachments_decorator.in_participation_module(with_archived: true), resource
      end

      participation_news.where(collections: { container: participation_process }).each do |resource|
        refute_includes news_decorator.in_participation_module, resource
        assert_includes news_decorator.in_participation_module(with_archived: true), resource
      end
    end

    def test_resources_of_draft_process
      participation_process.draft!

      participation_events.where(collections: { container: participation_process }).each do |resource|
        refute_includes events_decorator.in_participation_module, resource
        assert_includes events_decorator.in_participation_module(with_draft: true), resource
      end

      participation_attachments.where(collections: { container: participation_process }).each do |resource|
        refute_includes attachments_decorator.in_participation_module, resource
        assert_includes attachments_decorator.in_participation_module(with_draft: true), resource
      end

      participation_news.where(collections: { container: participation_process }).each do |resource|
        refute_includes news_decorator.in_participation_module, resource
        assert_includes news_decorator.in_participation_module(with_draft: true), resource
      end
    end

    def test_resources_with_term
      participation_events.where(collections: { container: participation_process }).each do |resource|
        assert_includes events_decorator.with_term(issue), resource
        assert_includes events_decorator.with_term(scope), resource
      end

      participation_process.update_attributes(scope_id: nil, issue_id: nil)

      participation_events.where(collections: { container: participation_process }).each do |resource|
        refute_includes events_decorator.with_term(issue), resource
        refute_includes events_decorator.with_term(scope), resource
      end
    end

    def test_in_process
      assert_equal events_decorator.in_process(participation_process), participation_events.where(collections: { container: participation_process })
      assert_equal attachments_decorator.in_process(participation_process), participation_attachments.where(collections: { container: participation_process })
      assert_equal news_decorator.in_process(participation_process), participation_news.where(collections: { container: participation_process })
    end
  end
end
