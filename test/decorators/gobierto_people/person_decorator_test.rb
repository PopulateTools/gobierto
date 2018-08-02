# frozen_string_literal: true

require "test_helper"
require "support/event_helpers"

module GobiertoPeople
  class PersonDecoratorTest < ActiveSupport::TestCase

    include ::EventHelpers

    def setup
      super
      @subject = PersonDecorator.new(person)
    end

    def person
      @person ||= gobierto_people_people(:richard)
    end

    def interest_group
      @interest_group ||= gobierto_people_interest_groups(:google)
    end

    def test_contact_email
      assert_nil @subject.contact_email
    end

    def test_twitter_handle
      assert_equal "@richard", @subject.twitter_handle
    end

    def test_twitter_url
      assert_equal "https://twitter.com/richard", @subject.twitter_url
    end

    def test_facebook_handle
      assert_equal "@richard", @subject.facebook_handle
    end

    def test_facebook_url
      assert_equal "https://facebook.com/richard", @subject.facebook_url
    end

    def test_linkedin_handle
      assert_equal "@richard", @subject.linkedin_handle
    end

    def test_linkedin_url
      assert_equal "https://linkedin.com/richard", @subject.linkedin_url
    end

    def test_instagram_handle
      assert_equal "@richard", @subject.instagram_handle
    end

    def test_instagram_url
      assert_equal "https://instagram.com/richard", @subject.instagram_url
    end

    def test_meetings_with_interest_groups
      person.events.destroy_all
      person.attending_events.destroy_all

      create_event(title: "Visible", person: person, interest_group: interest_group)
      create_event(title: "Hidden", person: person, interest_group: interest_group, state: :pending)

      event_titles = @subject.meetings_with_interest_groups.map(&:title)

      assert_equal event_titles, %w(Visible)
    end

  end
end
