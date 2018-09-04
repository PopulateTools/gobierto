# frozen_string_literal: true

require "test_helper"
require "support/concerns/user/subscribable_test"
require "support/concerns/gobierto_common/sluggable_test"

module GobiertoPeople
  class PersonTest < ActiveSupport::TestCase
    include User::SubscribableTest
    include GobiertoCommon::SluggableTestModule

    def person
      @person ||= gobierto_people_people(:richard)
    end
    alias subscribable person

    def new_person
      ::GobiertoPeople::Person.create!(name: "Person Name", site: sites(:madrid))
    end
    alias create_sluggable new_person

    def draft_person
      @draft_person ||= gobierto_people_people(:juana)
    end

    def site
      @site ||= sites(:madrid)
    end

    def admin
      @admin ||= gobierto_admin_admins(:nick)
    end

    def test_valid
      assert person.valid?
    end

    def test_collection_is_created
      person = ::GobiertoPeople::Person.create!(name: "New Person Name", site: sites(:madrid))
      assert person.events_collection.present?
    end

    def test_to_url
      assert_equal "http://#{person.site.domain}/personas/#{person.slug}", person.to_url
    end

    def test_public?
      assert person.public?
      refute draft_person.public?
    end

    def test_statements_url
      expected_url = "http://#{site.domain}/declaraciones/#{draft_person.slug}?preview_token=#{admin.preview_token}"

      assert_equal expected_url, draft_person.statements_url(preview: true, admin: admin)
    end

    def test_blog_url
      expected_url = "http://#{site.domain}/blogs/#{draft_person.slug}?preview_token=#{admin.preview_token}"

      assert_equal expected_url, draft_person.blog_url(preview: true, admin: admin)
    end

  end
end
