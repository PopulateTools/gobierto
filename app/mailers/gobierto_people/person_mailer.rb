# frozen_string_literal: true

module GobiertoPeople
  class PersonMailer < ApplicationMailer
    def new_message(args)
      @person = GobiertoPeople::Person.find(args[:person_id])
      @reply_to = args[:reply_to]
      @name = args[:name]
      @body = args[:body]
      @site = @person.site
      @site_host = site_host

      mail(
        from: from,
        to: @person.email,
        reply_to: @reply_to,
        subject: t(".subject", name: @site.title)
      )
    end
  end
end
