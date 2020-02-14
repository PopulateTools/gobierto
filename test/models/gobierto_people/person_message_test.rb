# frozen_string_literal: true

require "test_helper"

module GobiertoPeople
  class PersonMessageTest < ActiveSupport::TestCase
    def person
      @person ||= gobierto_people_people(:richard)
    end

    def subject
      @subject ||= GobiertoPeople::PersonMessage.new name: "Sender", email: "foo@example.com", person: person, body: "This is my message"
    end

    def test_valid
      assert subject.valid?
    end

    def test_deliver_method
      subject.deliver!
      refute ActionMailer::Base.deliveries.empty?
      email = ActionMailer::Base.deliveries.last

      assert_equal ["no-reply@gobierto.dev"], email.from
      assert_equal ["foo@example.com"], email.reply_to
      assert_equal [person.email], email.to
      assert_equal "You have received a new message from Transparencia y Participción", email.subject
    end
  end
end
