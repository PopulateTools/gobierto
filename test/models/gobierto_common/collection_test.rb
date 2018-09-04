# frozen_string_literal: true

require "test_helper"

module GobiertoCommon
  class CollectionTest < ActiveSupport::TestCase
    def site
      @site ||= sites(:madrid)
    end

    def process_collection
      @process_collection ||= gobierto_common_collections(:gender_violence_process_news)
    end

    def process_collection_container
      @process_collection_container ||= gobierto_participation_processes(:gender_violence_process)
    end
    alias process process_collection_container

    def page
      @page ||= gobierto_cms_pages(:generic_site_page)
    end

    def person
      @person ||= gobierto_people_people(:richard)
    end

    def create_collection(container, item_type)
      params = { site: site, title: "Title", item_type: item_type }

      if container.is_a? String
        params[:container_type] = container
      else
        params[:container] = container
      end

      Collection.create(params)
    end

    def test_append_in_a_process_collection
      assert_difference "GobiertoCommon::CollectionItem.count", 5 do
        process_collection.append(page)
      end

      assert GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container: site)
      assert GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container_type: "GobiertoParticipation")
      assert GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container: process_collection_container)
      assert GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container: process_collection_container.scope)
      assert GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container: process_collection_container.issue)
    end

    def test_container
      assert_equal process_collection_container, process_collection.container
      assert_equal ::GobiertoParticipation, GobiertoCommon::Collection.new(container_type: "GobiertoParticipation").container
    end

    def test_update_collection_container_should_update_collection_items
      process_collection.append(page)

      process_collection.container = site
      process_collection.save!

      assert GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container: site)
      refute GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container_type: "GobiertoParticipation")
      refute GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container: process_collection_container)
      refute GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container: process_collection_container.scope)
      refute GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: process_collection.item_type, collection: process_collection, container: process_collection_container.issue)
    end

    def test_update_collection_item_type
      process_collection.append(page)

      process_collection.item_type = "GobiertoCms::Page"
      process_collection.save!

      refute GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: "GobiertoCms::News", collection: process_collection, container: site)
      assert GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: "GobiertoCms::Page", collection: process_collection, container: site)
      refute GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: "GobiertoCms::News", collection: process_collection, container_type: "GobiertoParticipation")
      assert GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: "GobiertoCms::Page", collection: process_collection, container_type: "GobiertoParticipation")
      refute GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: "GobiertoCms::News", collection: process_collection, container: process_collection_container)
      assert GobiertoCommon::CollectionItem.exists?(item_id: page.id, item_type: "GobiertoCms::Page", collection: process_collection, container: process_collection_container)
    end

    def test_to_path
      process_events = create_collection(process, "GobiertoCalendars::Event")
      process_news = create_collection(process, "GobiertoCms::News")
      process_docs = create_collection(process, "GobiertoAttachments::Attachment")

      participation_events = create_collection("GobiertoParticipation", "GobiertoCalendars::Event")
      participation_news = create_collection("GobiertoParticipation", "GobiertoCms::News")
      participation_docs = create_collection("GobiertoParticipation", "GobiertoAttachments::Attachment")

      person_events = create_collection(person, "GobiertoCalendars::Event")

      site_pages = create_collection(site, "GobiertoCms::Page")
      site_news = create_collection(site, "GobiertoCms::News")

      assert_equal "/participacion/p/#{process.slug}/agendas", process_events.to_path
      assert_equal "/participacion/p/#{process.slug}/noticias", process_news.to_path
      assert_equal "/participacion/p/#{process.slug}/documentos", process_docs.to_path

      assert_equal "/participacion/agendas", participation_events.to_path
      assert_equal "/participacion/noticias", participation_news.to_path
      assert_equal "/participacion/documentos", participation_docs.to_path

      assert_equal "/agendas/#{person.slug}", person_events.to_path

      assert_equal "/paginas/#{site_pages.slug}", site_pages.to_path
      assert_equal "/noticias/#{site_news.slug}", site_news.to_path
    end

    def test_public?
      process_events = create_collection(process, "GobiertoCalendars::Event")
      person_events = create_collection(person, "GobiertoCalendars::Event")
      site_pages = create_collection(site, "GobiertoCms::Page")

      assert process_events.public?
      assert person_events.public?
      assert site_pages.public?

      process.draft!
      person.draft!
      site.draft!

      refute process_events.public?
      refute person_events.public?
      assert site_pages.public? # already protected via HTTP auth
    end

  end
end
